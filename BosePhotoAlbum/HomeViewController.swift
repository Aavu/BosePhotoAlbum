//
//  ViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var albums:[String] = []
    
    let uid = Auth.auth().currentUser?.uid
    var user:User?
    var album:Album?
    
    struct Storyboard {
        static let reuseID = "albumsCell"
        static let paddings:CGFloat = 2
        static let numberOfItemsPerRow:CGFloat = 2
        static let aspectRatio:CGFloat = 4.0/5.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let leftBarBtn = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        leftBarBtn.tintColor = .black
        navigationItem.leftBarButtonItem = leftBarBtn
        
        let rightBarBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlbum))
        rightBarBtn.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarBtn
        
        collectionView.register(AlbumsCell.self, forCellWithReuseIdentifier: Storyboard.reuseID)
        
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
        
        collectionView.backgroundColor = .white
        navigationItem.title = "Albums"
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectCell(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    
    func fetchAlbumsForCurrentUser() {
        let db = Firestore.firestore()
        db.collection("Albums").whereField("ownerID", isEqualTo: uid!).getDocuments { (snap, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            if let snap = snap {
                for doc in snap.documents {
                    self.albums.append(doc.data()["Name"] as! String)
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    @objc func addAlbum() {
        let alert = UIAlertController(title: "New Album", message: "Create a new album", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Untitled"
        }

        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if let txt = textField.text {
                let txtVal = self.appendCopy(txt: txt)
                if let user = self.user {
                    let album = Album(name: txtVal, owner: user)
                    album.addToFirestore()
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
    
    @objc func handleLogout() {
        print("logged out")
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
            return
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
    var selectionMode: Bool = false
    
    @objc func selectCell(sender: UILongPressGestureRecognizer) {
        if sender.state == .began && selectionMode == false {
            navigationController?.setToolbarHidden(false, animated: true)
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelecting))
            navigationItem.rightBarButtonItem = rightBarButton
            let point = sender.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: point)
            selectionMode = true
            if let indexPath = indexPath {
                print(indexPath.item)
            } else {
                print("Could not find index path")
            }
        }
        
    }
    
    @objc func cancelSelecting() {
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? AlbumsCell {
                    cell.isEditing = false
                    selectionMode = false
                    navigationItem.title = "Albums"
                    navigationItem.rightBarButtonItem = nil
                    navigationController?.setToolbarHidden(true, animated: true)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.reuseID, for: indexPath) as! AlbumsCell
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
        print(albums[indexPath.item])
        showControllerForAlbum(album: albums[indexPath.item])
    }
    
    func showControllerForAlbum(album:String) {
        let layout = UICollectionViewFlowLayout()
        let photosVC = PhotosViewController(collectionViewLayout: layout)
        photosVC.albumName = album
        self.navigationController?.pushViewController(photosVC, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.allowsMultipleSelection = editing
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? AlbumsCell {
                    cell.isEditing = editing
                    print(isEditing)
                }
            }
        }
    }
    
}

