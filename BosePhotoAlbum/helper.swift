//
//  helper.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/19/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

public extension Notification.Name {
    public static let playMusic = Notification.Name(rawValue: "playMusic")
    public static let nextSong = Notification.Name(rawValue: "nextSong")
    public static let prevSong = Notification.Name(rawValue: "prevSong")
    public static let showHidePlayer = Notification.Name(rawValue: "showHidePlayer")
}

extension UICollectionViewController {
    func select(indexPath:IndexPath, albums:Bool, selected: inout [IndexPath]) {
        if albums {
            let cell = self.collectionView.cellForItem(at: indexPath) as! AlbumsCell
            if selected.contains(indexPath) {
                cell.deleteBtn.isHidden = true
                let removeIndex = selected.firstIndex(of: indexPath)!
                selected.remove(at: removeIndex)
            } else {
                cell.deleteBtn.isHidden = false
                selected.append(indexPath)
            }
            navigationItem.title = "\(selected.count) Albums selected"
        }
        else {
            let cell = self.collectionView.cellForItem(at: indexPath) as! PhotosCell
            if selected.contains(indexPath) {
                cell.deleteBtn.isHidden = true
                let removeIndex = selected.firstIndex(of: indexPath)!
                selected.remove(at: removeIndex)
            } else {
                cell.deleteBtn.isHidden = false
                selected.append(indexPath)
            }
            navigationItem.title = "\(selected.count) Photos selected"
        }
    }
}
