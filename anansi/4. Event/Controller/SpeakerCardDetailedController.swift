//
//  PartnerAboutController.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 03/03/2018.
//  Copyright © 2018 João Apura. All rights reserved.
//

import UIKit

class SpeakerCardDetailedController: UIViewController, UIScrollViewDelegate {
    
    // Custom initializers
    let speakerDescriptions : [String : String] =
        ["speaker-p3dra" : "Singer and composer, Pedro has participated in projects like Meninos da Avó and 432, and he is well known in the field of musical performances and production of recreational-formative content. Curiosity: Pedro has given voice to the famous bear Balu, from the Book of the Jungle!",
         
         "speaker-winy" : "Master's student in Law, Winy is a women empowerer and comes to TEDxULisboa to tell us about the history of feminism and how some of the current trends are taking a different course, which contradicts its foundations.",
         
         "speaker-joaquim" : "Joaquim is a specialist in Navigation, Hydrography and Mathematical Cartography and a reformed Navy Officer. He leads the Medea-Chart research project at FCUL, where he develops innovative techniques for analyzing old cartography letters.",
         
         "speaker-marco" : "On several occasions, countered the medical expectations that inevitably would place him in a wheelchair. At TEDxULisboa, Marco is going to tell us how love, perseverance and strong will can change a life.",
         
         "speaker-leyla" : "Sociologist, designer and TED speaker, Leyla was awarded by UNEP as Earth Champion, in 2016. She is known for challenging the status quo on sustainability issues and recently founded a Spa for the mind and for the creatives, in Tomar, Portugal.",
         
         "speaker-bia" : "Since she was little she has interest in music. With Ricardo Quintas' help, Bia began to produce its own songs! Her enormous potential led Rui Carvalho to join the team and they are currently producing their first album of originals, after the recent release of Nevermind EP.",
         
         "speaker-ana" : "Political Science student at ISCSP, she is a human rights activist. At TEDxULisboa, Ana is going to talk about wardrobes, how to get out of them, and the best way to be ourselves.",
         
         "speaker-goncalo" : " Documentary photographer, decided to follow his passion for photography to give voice to those who don't have it. With focus on human right issues, Gonçalo has worked as a freelancer in multiple countries to witness and spread the injustices in the world.",
         
         "speaker-nuno" : "Survivor of bone cancer, Nuno amputated his left leg. Despite his disability, today he continues to practice sports and gymnastics and motivates others in similar situations. Nuno is coming to TEDxULisboa to show how he keeps his motivation high!",
         
         "speaker-rizumik" : "Musician, dancer, actor and beatbox champion! Having worked at Cirque du Soleil and THE VOCA PEOPLE, Tiago (Rizumik) values ​​mainly improvisation, humor and the art of movement in his performances. In his talk-performance, you will learn about the importance of improvisation in life!",
         
         "speaker-daniel" : "Passionate about the subjects that his Psychology programme teaches him. At TEDxULisboa, Daniel is going to explore the theme of loneliness in young people, adults and the elderly, in Portugal.",
         
         "speaker-joana" : "Science communicator and President of the SciComPt Network, Joana is the host of Antena 1 program \"90 seconds of science\", which challenges Portuguese researchers to share their work, improving the visibility of Science in Portugal.",
         
         "speaker-catarina" : "Worked for six years in a multinational company to quit and travel the world while developing skills and exploring her passions. Catarina has called this personal development program MLA - Master in Life Adventures."]
    
    var scheduleData : ScheduleData? {
        didSet {
            
            topbar.setTitle(name: scheduleData!.title)
            
            talkTitle.text = scheduleData!.description
            bioDescription.text = speakerDescriptions[scheduleData!.imageURL]
            speakerPic.image = UIImage(named: scheduleData!.imageURL)!.withRenderingMode(.alwaysOriginal)
            
            // Logs visit in firebase
            NetworkManager.shared.logEvent(name: "\(String(describing: scheduleData!.imageURL))_tap", parameters: nil)
        }
    }
    
    // NavBar
    
    lazy var topbar: TopBar = {
        let b = TopBar()
        b.setTitle(name: "Speaker")
        b.backgroundColor = .clear
        b.alpha(with: 0)
        b.titleLabel.alpha = 1.0
        b.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // View
    
    lazy var scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.backgroundColor = .background
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var backgroundImage: GradientView = {
        let v = GradientView()
        //v.mask = UIImageView(image: UIImage(named: "cover-users")?.withRenderingMode(.alwaysTemplate))
        //v.mask?.contentMode = .scaleToFill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let bioLabel : UILabel = {
        let l = UILabel()
        l.text = "Bio:"
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let talkLabel : UILabel = {
        let l = UILabel()
        l.text = "Talk:"
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let talkTitle : UILabel = {
        let l = UILabel()
        l.text = ""
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let bioDescription : UILabel = {
        let l = UILabel()
        l.text = ""
        l.formatTextWithLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, hyphenation: 0, alignment: .left)
        l.textColor = .secondary
        l.font = UIFont.systemFont(ofSize: Const.calloutFontSize)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let speakerPic : UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        i.backgroundColor = .clear
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    lazy var barHeight : CGFloat = (self.navigationController?.navigationBar.frame.height)!
    let statusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        // Sets up UI
        [scrollView, backgroundImage, topbar].forEach { view.addSubview($0) }
        scrollView.addSubview(contentView)
        [bioLabel, bioDescription, talkLabel, talkTitle, speakerPic].forEach { contentView.addSubview($0)}
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        setupNavigationBarItems()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // Navigation Bar was hidden in viewDidAppear
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        topbar.setStatusBarHeight(with: statusBarHeight)
        topbar.setNavigationBarHeight(with: barHeight)
        
        DispatchQueue.main.async {
            self.backgroundImage.applyGradient(withColours:
                [UIColor.primary.withAlphaComponent(0.1), .clear], gradientOrientation: .vertical)
        }
        
        NSLayoutConstraint.activate([
            
            // Navbar
            
            topbar.topAnchor.constraint(equalTo: view.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: barHeight + statusBarHeight),
            
            // View
            
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: topbar.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImage.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroundImage.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Const.marginSafeArea),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginSafeArea),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            
            bioDescription.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: Const.marginEight),
            bioDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginSafeArea),
            bioDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            
            talkLabel.topAnchor.constraint(equalTo: bioDescription.bottomAnchor, constant: Const.marginSafeArea),
            talkLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginSafeArea),
            talkLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            
            talkTitle.topAnchor.constraint(equalTo: talkLabel.bottomAnchor, constant: Const.marginEight),
            talkTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Const.marginSafeArea),
            talkTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Const.marginSafeArea),
            
            speakerPic.bottomAnchor.constraint(equalTo: backgroundImage.bottomAnchor),
            speakerPic.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            speakerPic.widthAnchor.constraint(equalToConstant: view.frame.height * 0.3),
            speakerPic.heightAnchor.constraint(equalToConstant: view.frame.height * 0.3),
        ])
    }
    
    private func setupNavigationBarItems() {
        
        //navigationItem.titleView = nil
        //navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Custom functions
    
    @objc func back() {
        
        navigationController?.popViewController(animated: true)
    }
}
