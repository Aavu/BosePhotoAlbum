//
//  SlideShowViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit

class SlideShowViewController: UIViewController {
    
    let slideShowImages = [UIImage(named: "pic1.png"), UIImage(named: "pic2.png"),
                           UIImage(named: "pic3.png"),UIImage(named: "pic4.png")]
    
    @IBOutlet weak var slideShowView: UIScrollView!
    
    @IBOutlet weak var createID_btn: UIButton!
    @IBOutlet weak var signIn_btn: UIButton!
    
    var currentSlide:CGFloat = 0
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        slideShowView.contentSize.width = slideShowView.frame.width * CGFloat(slideShowImages.count)
        slideShowView.bounces = false
        
        createID_btn.layer.masksToBounds = true
        createID_btn.layer.cornerRadius = createID_btn.frame.height/2
        
        signIn_btn.layer.masksToBounds = true
        signIn_btn.layer.cornerRadius = signIn_btn.frame.height/2
        signIn_btn.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        for i in 0..<slideShowImages.count {
            let imageView = UIImageView()
            imageView.image = slideShowImages[i]
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(x:Int(self.view.frame.width) * i, y: 0, width: Int(self.view.frame.width), height: Int(self.view.frame.height))
            slideShowView.addSubview(imageView)
        }
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.changeSlide), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func changeSlide() {
        if (Int(currentSlide) < slideShowImages.count-1) {
            currentSlide += 1
            slideShowView.setContentOffset(CGPoint(x: self.view.frame.width * currentSlide, y: 0), animated: true)
        } else {
            currentSlide = 0
            slideShowView.setContentOffset(CGPoint(x: self.view.frame.width * currentSlide, y: 0), animated: true)
        }
    }
    
    @IBAction func createID(_ sender: Any) {
    }
    
    @IBAction func signIn(_ sender: Any) {
    }
    
}
