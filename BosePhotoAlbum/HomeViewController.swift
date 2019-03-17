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
        
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        }
        
        collectionView.backgroundColor = .white
    }
    
    @objc func addAlbum() {
        let alert = UIAlertController(title: "New Album", message: "Create a new album", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Untitled Album"
        }

        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if let txt = textField.text {
                if !self.albums.contains(txt) {
                    self.albums.append(txt)
                } else {
                    self.albums.append(txt + " copy")
                }
                self.collectionView.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
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
    }

}

