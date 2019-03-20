//
//  ViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var audioPlayer:AVAudioPlayer!
    let songsList = ["song1", "song2", "song3"]
    var songs:[URL] = []
    var albums:[String] = []
    var albumIDs:[String] = []
    let uid = Auth.auth().currentUser?.uid
    var user:User?
    var album:Album?
    
    let db = Firestore.firestore()
    
    let reuseID = "albumsCell"
    
    var selectionMode = false
    
    var selectedAlbumsIndexPath:[IndexPath] = [] {
        didSet {
            if (selectedAlbumsIndexPath.count > 1 || selectedAlbumsIndexPath.count == 0)  {
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    let window = UIApplication.shared.keyWindow
    
    let musicPlayerView = MusicPlayerView()
    
    var musicPlayerHidden = false
    
    let musicPlayerHeight:CGFloat = 84
    var musicPlaying = false
    
    var musicPlayerBottomAnchorConstraintToWindow:NSLayoutConstraint?
    var musicPlayerBottomAnchorConstraintToToolbar:NSLayoutConstraint?
    var musicPlayerTopAnchorConstraintToWindow:NSLayoutConstraint?
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        collectionView.register(AlbumsCell.self, forCellWithReuseIdentifier: reuseID)
        
        refreshData()
        
        initEditMode()
        collectionView.backgroundColor = .white
        view.addSubview(progressView)
        progressView.center = view.center
        progressView.hidesWhenStopped = true
        
        setupMusicPlayerView()
        setupAudioPlayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showHidePlayer), name: .showHidePlayer, object: nil)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc func refreshData() {
        if let uid = uid {
            let currentUserDetails = Database.database().reference().child("users").child(uid)
            currentUserDetails.observeSingleEvent(of: .value) { (snap) in
                if let d = snap.value as? [String: AnyObject] {
                    self.user = User(firstName: d["firstName"] as? String, lastName: d["lastName"] as? String, email: d["email"] as? String, id: uid)
                    self.fetchAlbumsForCurrentUser()
                }
            }
        } else {
            handleLogout()
        }
    }
    
    @objc func showHidePlayer() {
        if musicPlayerHidden {
            if selectionMode {
                musicPlayerTopAnchorConstraintToWindow?.isActive = false
                musicPlayerBottomAnchorConstraintToWindow?.isActive = false
                musicPlayerBottomAnchorConstraintToToolbar?.isActive = true
            } else {
                musicPlayerBottomAnchorConstraintToToolbar?.isActive = false
                musicPlayerTopAnchorConstraintToWindow?.isActive = false
                musicPlayerBottomAnchorConstraintToWindow?.isActive = true
            }
        } else {
            musicPlayerBottomAnchorConstraintToWindow?.isActive = false
            musicPlayerBottomAnchorConstraintToToolbar?.isActive = false
            musicPlayerTopAnchorConstraintToWindow?.isActive = true
        }
        UIView.animate(withDuration: 0.25) {
            self.window?.layoutIfNeeded()
        }
        musicPlayerHidden.toggle()
    }
    
    func setupNavBar() {
        navigationItem.title = "Albums"
        let leftBarBtn = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem = leftBarBtn
        
        let rightBarBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlbum))
        navigationItem.rightBarButtonItem = rightBarBtn
        
        let leftToolBarBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleTrash))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let rightToolBarBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelecting))
        
        setToolbarItems([leftToolBarBtn, space, rightToolBarBtn], animated: false)
    }
    
    func initEditMode() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectCell(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func setupMusicPlayerView() {
        if let window = window {
            musicPlayerBottomAnchorConstraintToWindow = musicPlayerView.bottomAnchor.constraint(equalTo: window.layoutMarginsGuide.bottomAnchor, constant: 0)
            
            musicPlayerBottomAnchorConstraintToToolbar = musicPlayerView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -musicPlayerHeight)
            
            musicPlayerTopAnchorConstraintToWindow = musicPlayerView.topAnchor.constraint(equalTo: window.bottomAnchor)
            
            window.addSubview(musicPlayerView)
            musicPlayerView.leftAnchor.constraint(equalTo: window.layoutMarginsGuide.leftAnchor).isActive = true
            musicPlayerView.rightAnchor.constraint(equalTo: window.layoutMarginsGuide.rightAnchor).isActive = true
            musicPlayerBottomAnchorConstraintToWindow!.isActive = true
            musicPlayerView.heightAnchor.constraint(equalToConstant: musicPlayerHeight).isActive = true
            musicPlayerView.layer.cornerRadius = musicPlayerHeight/2
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playPauseMusic), name: .playMusic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nextSong), name: .nextSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(prevSong), name: .prevSong, object: nil)
    }
    
    func setupAudioPlayer() {
        for song in songsList {
            songs.append(URL(fileURLWithPath: Bundle.main.path(forResource: song, ofType: "mp3")!))
        }
        playSong(url: songs[0])
    }
    
    func playSong(url:URL) {
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch {
            print("error in audio player init")
        }
    }
    
    @objc func playPauseMusic() {
        musicPlaying = audioPlayer.isPlaying
        if musicPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
        musicPlayerView.togglePlayIcon(playing: musicPlaying)
    }
    
    var idx = 0
    
    @objc func nextSong() {
        idx = (idx + 1) % songs.count
        playSong(url: songs[idx])
    }
    
    @objc func prevSong() {
        idx = (idx - 1) % songs.count
        if idx < 0 {
            idx = songs.count + idx
        }
        playSong(url: songs[idx])
    }
    
    let progressView = UIActivityIndicatorView(style: .gray)
    
    var reloadData = false {
        didSet {
            if reloadData {
                self.collectionView.reloadData()
            }
        }
    }
    
    func fetchAlbumsForCurrentUser() {
        progressView.startAnimating()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        self.albumIDs = []
        self.albums = []
        db.collection("Albums").whereField("ownerID", isEqualTo: uid!).getDocuments { (snap, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }

            if let snap = snap {
                for doc in snap.documents {
                    self.albumIDs.append(doc.documentID)
                    self.albums.append(doc.data()["Name"] as! String)
                    self.reloadData = true
                }
                print(self.albums, self.albumIDs)
            }
        }
        self.refreshControl.endRefreshing()
        self.progressView.stopAnimating()
    }
    
    @objc func addAlbum() {
        let alert = UIAlertController(title: "New Album", message: "Create a new album", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Untitled"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if let txt = textField.text {
                let txtVal = self.appendCopy(txt: txt)
                if let user = self.user {
                    let album = Album(name: txtVal, owner: user)
                    album.addToFirestore()
                    self.db.collection("Albums").whereField("ownerID", isEqualTo: user.id).whereField("Name", isEqualTo: txtVal).getDocuments { (snap, error) in
                        if let id = snap?.documents.first?.documentID {
                            self.albumIDs.append(id)
                        }
                    }
                }
                self.collectionView.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func appendCopy(txt:String) -> String {
        var t = txt
        var i = 1
        while self.albums.contains(t) {
            t = txt + String(i)
            i += 1
        }
        self.albums.append(t)
        return t
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: true)
                nav.viewControllers = []
                musicPlayerView.removeFromSuperview()
                let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signInVC")
                nav.setViewControllers([signInVC], animated: true)
            }
        } catch let logoutError {
            print(logoutError)
            return
        }
    }
    
    @objc func selectCell(sender: UILongPressGestureRecognizer) {
        if sender.state == .began && selectionMode == false {
            selectionMode()
            let point = sender.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: point)
            if let indexPath = indexPath {
                self.select(indexPath: indexPath, albums: true, selected: &selectedAlbumsIndexPath)
            } else {
                print("Could not find index path")
            }
        }
        
    }
    
    func selectionMode(enter:Bool = true) {
        selectionMode = enter
        navigationController?.setToolbarHidden(!enter, animated: true)
        navigationItem.leftBarButtonItem?.isEnabled = !enter
        musicPlayerBottomAnchorConstraintToWindow?.isActive = !enter
        musicPlayerBottomAnchorConstraintToToolbar?.isActive = enter
        UIView.animate(withDuration: 0.25) {
            self.window?.layoutIfNeeded()
        }
        var rightBarButton:UIBarButtonItem?
        if enter {
            rightBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleSharing))
        } else {
            if let indexPaths = collectionView?.indexPathsForVisibleItems {
                for indexPath in indexPaths {
                    if let cell = collectionView?.cellForItem(at: indexPath) as? AlbumsCell {
                        cell.isEditing = false
                    }
                }
            }
            navigationItem.title = "Albums"
            rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlbum))
            selectedAlbumsIndexPath.removeAll()
        }
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func handleSharing() {
        let albumID = albumIDs[selectedAlbumsIndexPath[0].item]
        let albumName = albums[selectedAlbumsIndexPath[0].item]
        let url = "abpa://\(uid!)@BosePhotoAlbum/?album=1&mediaID=\(albumID)&albumName=\(albumName)&token=0".addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: " \n\r").inverted)
        
        let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        activityVC.setValue("Link to \(albumName) - Bose Photo Album", forKey: "subject")
        activityVC.popoverPresentationController?.sourceView = self.view
        showHidePlayer()
        
        activityVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            self.showHidePlayer()
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func handleTrash() {
        let array = Array(selectedAlbumsIndexPath.sorted().reversed())
        
        var toRemove:[String] = []
        
        for index in array {
            if self.albums.indices.contains(index.row) {
                toRemove.append(self.albumIDs[index.item])
                self.albums.remove(at: index.item)
            }
        }
        for albumID in toRemove {
            db.collection("Albums").document(albumID).delete { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.collectionView.reloadData()
            }
        }
        selectionMode(enter: false)
    }
    
    @objc func cancelSelecting() {
        selectionMode(enter:false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! AlbumsCell
        cell.albumLabel.text = albums[indexPath.item]
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 125)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !selectionMode {
            showControllerForAlbum(album: albums[indexPath.item], albumID: albumIDs[indexPath.item])
        } else {
            self.select(indexPath: indexPath, albums: true, selected: &selectedAlbumsIndexPath)
        }
    }
    
    func showControllerForAlbum(album:String, albumID:String) {
        let layout = UICollectionViewFlowLayout()
        let photosVC = PhotosViewController(collectionViewLayout: layout)
        photosVC.albumName = album
        photosVC.albumID = albumID
        photosVC.musicPlayerView = musicPlayerView
        photosVC.musicPlayerBottomAnchorConstraintToWindow = musicPlayerBottomAnchorConstraintToWindow
        photosVC.musicPlayerBottomAnchorConstraintToToolbar = musicPlayerBottomAnchorConstraintToToolbar
        navigationController?.pushViewController(photosVC, animated: true)
    }
    
}
