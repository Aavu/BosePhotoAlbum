//
//  PhotosViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/18/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "photosCell"

class PhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageVC = ImageViewController()
    let progressView = UIActivityIndicatorView(style: .gray)
    
    let window = UIApplication.shared.keyWindow
    
    var musicPlayerView:UIView!
    
    var musicPlayerBottomAnchorConstraintToWindow:NSLayoutConstraint?
    var musicPlayerBottomAnchorConstraintToToolbar:NSLayoutConstraint?
    
    var photos:[UIImage] = []
    var imageURL:[String] = []
    
    var albumName:String!
    
    let uid = Auth.auth().currentUser?.uid
    var user:User?
    var albums:[Album] = []
    let picker = UIImagePickerController()
    
    var selectionMode: Bool = false
    
    let db = Firestore.firestore()
    
    var rightBarBtn:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightBarBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        let leftToolBarBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleTrash))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let rightToolBarBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelecting))
        
        setToolbarItems([leftToolBarBtn, space, rightToolBarBtn], animated: false)
        
        // Register cell classes
        self.collectionView!.register(PhotosCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = rightBarBtn
        
        collectionView.backgroundColor = .white
        navigationItem.title = albumName
        
        fetchPhotosForAlbum()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectCell(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressGesture)
        
        view.addSubview(progressView)
        progressView.center = view.center
        progressView.hidesWhenStopped = true
    }
    
    @objc func selectCell(sender: UILongPressGestureRecognizer) {
        if sender.state == .began && selectionMode == false {
            selectionMode()
            let point = sender.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: point)
            if let indexPath = indexPath {
                self.select(indexPath: indexPath, albums: false, selected: &selectedPhotosIndexPath)
            } else {
                print("Could not find index path")
            }
        }
    }
    
    func selectionMode(enter:Bool = true) {
        selectionMode = enter
        navigationController?.setToolbarHidden(!enter, animated: true)
        navigationItem.setHidesBackButton(enter, animated: true)
        if enter {
            musicPlayerBottomAnchorConstraintToWindow?.isActive = false
            musicPlayerBottomAnchorConstraintToToolbar?.isActive = true
        } else {
            musicPlayerBottomAnchorConstraintToToolbar?.isActive = false
            musicPlayerBottomAnchorConstraintToWindow?.isActive = true
        }
        UIView.animate(withDuration: 0.25) {
            self.window?.layoutIfNeeded()
        }
        var rightBarButton:UIBarButtonItem?
        if enter {
            rightBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelecting))
        } else {
            if let indexPaths = collectionView?.indexPathsForVisibleItems {
                for indexPath in indexPaths {
                    if let cell = collectionView?.cellForItem(at: indexPath) as? PhotosCell {
                        cell.isEditing = false
                    }
                }
            }
            navigationItem.title = albumName
            rightBarButton = nil
            selectedPhotosIndexPath.removeAll()
        }
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func handleTrash() {
        print("removed from db")
        selectionMode(enter: false)
    }
    
    var selectedPhotosIndexPath:[IndexPath] = []
    
    @objc func cancelSelecting() {
        selectionMode(enter:false)
    }
    
    
    var reloadData = false {
        didSet {
            if reloadData {
                self.collectionView.reloadData()
            }
        }
    }
    
    func fetchPhotosForAlbum() {
        progressView.startAnimating()
        db.collection("Albums").whereField("Name", isEqualTo: self.albumName).whereField("ownerID", isEqualTo: self.uid!).getDocuments { (snap, e) in
            if let e = e {
                print(e.localizedDescription)
                return
            }
            
            if let snap = snap {
                if let url = snap.documents.first {
                    self.imageURL = url.data()["imageURL"] as? [String] ?? []
                }
            }
            
            if self.imageURL.count > 0 {
                DispatchQueue.global(qos: .background).async {
                    for url in self.imageURL {
                        URLSession.shared.dataTask(with: URL(string:url)!, completionHandler: { (data, response, dataTaskError) in
                            if let dataTaskError = dataTaskError {
                                print(dataTaskError.localizedDescription)
                                return
                            }
                            DispatchQueue.main.async {
                                self.progressView.stopAnimating()
                                
                                if let data = data {
                                    if let image = UIImage(data: data) {
                                        self.photos.append(image)
                                        self.reloadData = true
                                    }
                                }
                            }
                        }).resume()
                    }
                }
            } else {
                self.progressView.stopAnimating()
                print("no data")
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCell
        cell.imageView.image = photos[indexPath.item]
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.6
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        return cell
    }
    
    @objc func addPhoto() {
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: {
            let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.photos.append(img)
            
            let uuid = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("\(uuid).jpg")
            let lowImage = self.resizeImage(image: img, scaleFactor: 0.1)
            print(img.size, lowImage!.size)
            if let imgData = lowImage!.jpegData(compressionQuality: 0) {
                storageRef.putData(imgData, metadata: nil, completion: { (metadata, err) in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        let albumsDB = self.db.collection("Albums")
                        albumsDB.whereField("Name", isEqualTo: self.albumName).whereField("ownerID", isEqualTo: self.uid!).getDocuments { (snap, e) in
                            if let e = e {
                                print(e.localizedDescription)
                                return
                            }
                            
                            if let snap = snap?.documents.first {
                                if let url = url?.absoluteString {
                                    self.imageURL.append(url)
                                    let data:[String : Any] = ["imageURL":self.imageURL]
                                    albumsDB.document(snap.documentID).setData(data, merge: true, completion: { (addUrlError) in
                                        if let addUrlError = addUrlError {
                                            print(addUrlError.localizedDescription)
                                            return
                                        }
                                        print("Successfully added url")
                                    })
                                }
                            }
                        }
                        
                    })
                })
            }
            
            self.collectionView.reloadData()
        })
    }
    
    func resizeImage(image: UIImage,scaleFactor:CGFloat) -> UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
//        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (self.view.frame.width/4) - 9
        return CGSize(width: w, height: w)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !selectionMode {
            imageVC.image = photos[indexPath.item]
            navigationController?.pushViewController(imageVC, animated: true)
        } else {
            self.select(indexPath: indexPath, albums: false, selected: &selectedPhotosIndexPath)
        }
    }

}
