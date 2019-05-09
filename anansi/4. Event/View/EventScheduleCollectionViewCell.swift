//
//  EventScheduleCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

struct ScheduleData {
    var type = String()
    var title = String()
    var description = String()
    var location = String()
    var imageURL = String()
}

protocol ShowSpeakerDetailedPageDelegate: class {
    func showSpeakerDetailedPageWith(data: ScheduleData)
    func showUserPageWith(id: String)
}

class EventScheduleCollectionViewCell: UICollectionViewCell {
    
    // Custom Initializers
    
    var delegate: ShowSpeakerDetailedPageDelegate?
    
    let sectionTitle : [String] = ["09:00 Check-in", "10:00 Session 1: South", "12:00 Lunch break", "13:30 Session 2: East", "15:00 Coffee-break", "16:30 Session 3: West", "18:00 Closing remarks"]
    
    let schedule : [Int : [ScheduleData]] =
        [0 : [ScheduleData(type: "info", title: "Check-in & xChallenge kick-off", description: "Get your badge and goodie bag.", location: "Edifício da Reitoria", imageURL: ""),
              ScheduleData(type: "activity", title: "Filipa e Rita Barreiros", description: "Live performance.", location: "Salão Nobre", imageURL: "No7Qlm96VRNn7RYEIXV4Sjo7E0m2")],
         
         1 : [ScheduleData(type: "talk", title: "P3DRA", description: "Há um caminho certo?", location: "Aula Magna", imageURL: "speaker-p3dra"),
              ScheduleData(type: "talk", title: "Winy Mule", description: "Does radical feminism represent us?", location: "Aula Magna", imageURL: "speaker-winy"),
              ScheduleData(type: "talk", title: "Joaquim Alves Gaspar", description: "Seria a Terra redonda em 1500?", location: "Aula Magna", imageURL: "speaker-joaquim"),
              ScheduleData(type: "talk", title: "Marco Rodrigues", description: "O amor pode transformar uma vida", location: "Aula Magna", imageURL: "speaker-marco"),
              ScheduleData(type: "talk", title: "Leyla Acaroglu", description: "How do we value invisible things?", location: "Aula Magna", imageURL: "speaker-leyla")],
         
         2 : [ScheduleData(type: "info", title: "Lunch", description: "Enjoy our food trucks outside!", location: "Alameda da Universidade", imageURL: ""),
              ScheduleData(type: "activity", title: "Activities", description: "Yoga & mindfulness", location: "Alameda da Universidade", imageURL: "Ag6eSDTy6vcD0hJTOEnGOiib7OB2")],
         
         3 : [ScheduleData(type: "talk", title: "Bia Berry", description: "The Melodies in my Head", location: "Aula Magna", imageURL: "speaker-bia"),
              ScheduleData(type: "talk", title: "Gonçalo Fonseca", description: "Endurance as the key to success", location: "Aula Magna", imageURL: "speaker-goncalo"),
              ScheduleData(type: "talk", title: "Ana Basílio", description: "A importância de sermos nós próprios", location: "Aula Magna", imageURL: "speaker-ana"),
              ScheduleData(type: "talk", title: "Nuno Santos", description: "Create your own path", location: "Aula Magna", imageURL: "speaker-nuno")],
         
         4 : [ScheduleData(type: "info", title: "Coffee-break", description: "Network with other attendees while enjoying a cup of coffee.", location: "Edifício da Reitoria", imageURL: ""),
              ScheduleData(type: "activity", title: "Mistah Isaac", description: "Live performance", location: "Salão Nobre", imageURL: "Adm3HuORGBZ2TAFt0xunYs7K6Is2")],
    
         5 : [ScheduleData(type: "talk", title: "Rizumik", description: "Spontane-Us", location: "Aula Magna", imageURL: "speaker-rizumik"),
              ScheduleData(type: "talk", title: "Daniel Caramujo", description: "Loneliness: public enemy number one", location: "Aula Magna", imageURL: "speaker-daniel"),
              ScheduleData(type: "talk", title: "Joana Lobo Antunes", description: "What we talk about when we talk about scientists", location: "Aula Magna", imageURL: "speaker-joana"),
              ScheduleData(type: "talk", title: "Catarina Holstein", description: "Master in Life Adventures – using the World as a Classroom", location: "Aula Magna", imageURL: "speaker-catarina")],
         
         6 : [ScheduleData(type: "info", title: "Closing remarks", description: "Farewell and xChallenge winners announcement", location: "Aula Magna", imageURL: "")]]
    
    let info = "ScheduleInfoTableCell"
    let talk = "ScheduleTalkTableCell"
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(ScheduleInfoTableViewCell.self, forCellReuseIdentifier: info)
        tv.register(ScheduleTalkTableViewCell.self, forCellReuseIdentifier: talk)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.separatorStyle = .none
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.estimatedRowHeight = 128.0
        tv.rowHeight = UITableView.automaticDimension
        tv.showsVerticalScrollIndicator = false
        //tv.allowsSelection = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.marginSafeArea),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.marginSafeArea),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Custom functions
    
}

// MARK: UITableViewDelegate

extension EventScheduleCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule[section]!.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UIView()
        v.backgroundColor = .background
        
        let t = UILabel()
        t.text = sectionTitle[section]
        t.textColor = .secondary
        t.font = UIFont.boldSystemFont(ofSize: Const.bodyFontSize)
        t.translatesAutoresizingMaskIntoConstraints = false
        
        let l = UIView()
        l.backgroundColor = .tertiary
        l.translatesAutoresizingMaskIntoConstraints = false
        
        v.addSubview(t)
        v.addSubview(l)
        
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .leading, relatedBy: .equal, toItem: v, attribute: .leading, multiplier: 1.0, constant: 0.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .trailing, relatedBy: .equal, toItem: l, attribute: .leading, multiplier: 1.0, constant: -16.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1.0, constant: 6.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .bottom, relatedBy: .equal, toItem: v, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1.0, constant: -0.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .centerY, relatedBy: .equal, toItem: t, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        return v
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if schedule[section]![row].type == "info" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: info, for: indexPath) as! ScheduleInfoTableViewCell
            
            cell.cardTitle.text = schedule[section]![row].title
            cell.cardDescription.text = schedule[section]![row].description
            cell.cardLocation.text = schedule[section]![row].location
            
            cell.selectedBackgroundView = createSpecialViewWithBackgroundColor(.clear)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: talk, for: indexPath) as! ScheduleTalkTableViewCell
            
            cell.type = schedule[section]![row].type
            cell.cardTitle.text = schedule[section]![row].title
            cell.cardDescription.text = schedule[section]![row].description
            cell.cardLocation.text = schedule[section]![row].location
            
            let imagePath = schedule[section]![row].imageURL
            if imagePath != "" {
                cell.speakerPic.image = UIImage(named: imagePath)?.withRenderingMode(.alwaysOriginal)
                cell.speakerPic.isHidden = false
            }
            
            cell.selectedBackgroundView = createSpecialViewWithBackgroundColor(.clear)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        let section = indexPath.section
        let row = indexPath.row
        
        return !(schedule[section]![row].type == "info")
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        let scheduleData = schedule[section]![row]
        
        if scheduleData.type == "talk" {
            delegate?.showSpeakerDetailedPageWith(data: scheduleData)
        } else {
            let userID = scheduleData.imageURL
            delegate?.showUserPageWith(id: userID)
        }
        
    }
}
