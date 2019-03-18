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
    
    var photos:[UIImage] = []
    var imageURL:[String] = []
    
    var albumName:String!
    
    let uid = Auth.auth().currentUser?.uid
    var user:User?
    var albums:[Album] = []
    let picker = UIImagePickerController()
    
    var selectionMode: Bool = false
    
    let db = Firestore.firestore()
    
    let rightBarBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        // Register cell classes
        self.collectionView!.register(PhotosCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        rightBarBtn.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarBtn
        
        collectionView.backgroundColor = .white
        navigationItem.title = albumName
        
        fetchPhotosForAlbum()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectCell(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func selectCell(sender: UILongPressGestureRecognizer) {
        if sender.state == .began && selectionMode == false {
            navigationController?.setToolbarHidden(false, animated: true)
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelecting))
            navigationItem.rightBarButtonItem = rightBarButton
            let point = sender.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: point)
            selectionMode = true
            if let indexPath = indexPath {
                select(indexPath: indexPath)
            } else {
                print("Could not find index path")
            }
        }
    }
    
    var selectedPhotosIndexPath:[IndexPath] = []
    
    func select(indexPath:IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath) as! PhotosCell
        print(selectedPhotosIndexPath)
        if selectedPhotosIndexPath.contains(indexPath) {
            cell.deleteBtn.isHidden = true
            let removeIndex = selectedPhotosIndexPath.firstIndex(of: indexPath)!
            selectedPhotosIndexPath.remove(at: removeIndex)
//            photos.remove(at: removeIndex)
//            imageURL.remove(at: removeIndex)
        } else {
            cell.deleteBtn.isHidden = false
            selectedPhotosIndexPath.append(indexPath)
        }
        navigationItem.title = "\(selectedPhotosIndexPath.count) photos selected"
    }
    
    @objc func cancelSelecting() {
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
                    cell.isEditing = false
                }
            }
            selectionMode = false
            navigationItem.title = albumName
            navigationItem.rightBarButtonItem = rightBarBtn
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    func fetchPhotosForAlbum() {
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
            
            DispatchQueue.global(qos: .background).async {
                do
                {
                    for url in self.imageURL {
                        let data = try Data.init(contentsOf: URL(string:url)!)
                        DispatchQueue.main.async {
                            let image: UIImage = UIImage(data: data)!
                            self.photos.append(image)
                            self.collectionView.reloadData()
                        }
                    }
                }
                catch {
                    print("error")
                }
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
            
            if let imgData = img.jpegData(compressionQuality: 0) {
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
            select(indexPath: indexPath)
        }
    }

}
