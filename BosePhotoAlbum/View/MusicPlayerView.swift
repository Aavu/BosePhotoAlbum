//
//  MusicPlayerView.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/19/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

class MusicPlayerView: UIView {
    
    let playBtnHeight:CGFloat = 60
    let nextBtnHeight:CGFloat = 54
    
    let playPauseBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "pause.png"), for: .normal)
        btn.addTarget(self, action: #selector(playPauseMusic), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let insetSize:CGFloat = 10
    
    let nextBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.backgroundColor = .darkGray
        btn.addTarget(self, action: #selector(nextSong), for: .touchUpInside)
        btn.setImage(UIImage(named: "nextSong.png"), for: .normal)
        btn.layer.masksToBounds = true
        return btn
    }()
    
    let prevBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(prevSong), for: .touchUpInside)
        btn.setImage(UIImage(named: "prevSong.png"), for: .normal)
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.75
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.addSubview(playPauseBtn)
        self.addSubview(prevBtn)
        self.addSubview(nextBtn)
        playPauseBtn.heightAnchor.constraint(equalToConstant: playBtnHeight).isActive = true
        playPauseBtn.widthAnchor.constraint(equalTo: playPauseBtn.heightAnchor).isActive = true
        playPauseBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playPauseBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        playPauseBtn.layer.cornerRadius = playBtnHeight/2
        
        prevBtn.heightAnchor.constraint(equalToConstant: nextBtnHeight).isActive = true
        prevBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        prevBtn.trailingAnchor.constraint(equalTo: playPauseBtn.leadingAnchor, constant: -24).isActive = true
        prevBtn.widthAnchor.constraint(equalTo: prevBtn.heightAnchor).isActive = true
        prevBtn.layer.cornerRadius = nextBtnHeight/2
        
        nextBtn.heightAnchor.constraint(equalToConstant: nextBtnHeight).isActive = true
        nextBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        nextBtn.leadingAnchor.constraint(equalTo: playPauseBtn.trailingAnchor, constant: 24).isActive = true
        nextBtn.widthAnchor.constraint(equalTo: nextBtn.heightAnchor).isActive = true
        nextBtn.layer.cornerRadius = nextBtnHeight/2
        
        playPauseBtn.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        prevBtn.imageEdgeInsets = UIEdgeInsets(top: insetSize, left: insetSize, bottom: insetSize, right: insetSize)
        nextBtn.imageEdgeInsets = UIEdgeInsets(top: insetSize, left: insetSize, bottom: insetSize, right: insetSize)
    }
    
    func togglePlayIcon(playing:Bool) {
        if playing {
            playPauseBtn.setImage(UIImage(named: "play.png"), for: .normal)
        } else {
            playPauseBtn.setImage(UIImage(named: "pause.png"), for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func playPauseMusic() {
        NotificationCenter.default.post(name: .playMusic, object: nil)
    }
    
    @objc func nextSong() {
        NotificationCenter.default.post(name: .nextSong, object: nil)
    }
    
    @objc func prevSong() {
        NotificationCenter.default.post(name: .prevSong, object: nil)
    }

}
