//
//  EventScheduleCollectionViewCell.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 14/04/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class EventScheduleCollectionViewCell: UICollectionViewCell {
    
    // Custom Initializers
    
    let sectionTitle : [String] = ["09:00 Check-in", "10:00 Session 1: South", "12:00 Lunch break", "13:30 Session 2: East", "15:00 Coffee-break", "16:30 Session 3: West", "18:00 Closing remarks"]
    
    let data : [Int : [[String]]] = [0 : [["info", "Check-in", "Acreditation and reception", "Edifício da Reitoria", ""],
                                          ["info", "xChallenge kick-off!", "Can you find your north?", "Edifício da Reitoria", ""],
                                          ["info", "(nome artista)", "Live performance", "Salão Nobre", ""]],
                                     1 : [["talk", "Bia Berry", "TBD (PT)", "Aula Magna", "speaker-bia"],
                                          ["talk", "Ana Basílio", "Labels and closets: how to get rid of them", "Aula Magna", "speaker-ana"],
                                          ["talk", "Joaquim Cabral", "Seria a Terra redonda em 1500? (PT)", "Aula Magna", "speaker-joaquim"],
                                          ["talk", "Marco Rodrigues", "O amor pode transformar uma vida (PT)", "Aula Magna", "speaker-marco"],
                                          ["talk", "Gonçalo Fonseca", "Endurance as the key to success", "Aula Magna", "speaker-goncalo"]],
                                     2 : [["info", "Lunch", "Enjoy our food trucks outside!", "Alameda da Universidade", ""],
                                          ["info", "Activities", "Yoga & mindfulness", "Alameda da Universidade", ""]],
                                     3 : [["talk", "Rizumik", "Improvisation as a way to live in the moment", "Aula Magna", "speaker-rizumik"],
                                          ["talk", "Daniel Caramujo", "Loneliness: public enemy number one", "Aula Magna", "speaker-daniel"],
                                          ["talk", "Winy Mule", "Feminism 101", "Aula Magna", "speaker-winy"],
                                          ["talk", "Leyla Acaroglu", "Economy 2.0", "Aula Magna", "speaker-leyla"]],
                                     4 : [["info", "Coffee-break", "(insert description)", "Edifício da Reitoria", ""],
                                          ["info", "Mistah Isaac", "Live performance", "Salão Nobre", ""]],
                                     5 : [["talk", "P3dra", "TBD (PT)", "Aula Magna", "speaker-p3dra"],
                                          ["talk", "Nuno Santos", "Cut the bullsh*t!", "Aula Magna", "speaker-nuno"],
                                          ["talk", "Joana Lobo Antunes", "What does a scientist look like? (PT?)", "Aula Magna", "speaker-joana"],
                                          ["talk", "Catarina Holstein,", "Master in Life Adventures – using the World as a Classroom", "Aula Magna", "speaker-catarina"]],
                                     6 : [["info", "Closing remarks", "Farewell and xChallenge winners", "Aula Magna", ""]]]
    
    let identifier = "ScheduleTableCell"
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(ScheduleTableViewCell.self, forCellReuseIdentifier: identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .background
        tv.alwaysBounceVertical = true
        tv.separatorStyle = .none
        tv.sectionHeaderHeight = 56.0
        tv.estimatedSectionHeaderHeight = 56.0
        tv.estimatedRowHeight = 128.0
        tv.rowHeight = UITableViewAutomaticDimension
        tv.showsVerticalScrollIndicator = false
        tv.allowsSelection = false;
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
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
        return data[section]!.count
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
        
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .leading, relatedBy: .equal, toItem: v, attribute: .leading, multiplier: 1.0, constant: 24.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .trailing, relatedBy: .equal, toItem: l, attribute: .leading, multiplier: 1.0, constant: -16.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1.0, constant: 6.0))
        v.addConstraint(NSLayoutConstraint(item: t, attribute: .bottom, relatedBy: .equal, toItem: v, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1.0, constant: -24.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0))
        v.addConstraint(NSLayoutConstraint(item: l, attribute: .centerY, relatedBy: .equal, toItem: t, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        return v
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ScheduleTableViewCell
        
        // [1] - title [2] - description [3] - location [4] - picture
        
        cell.cardTitle.text = data[section]![row][1]
        
        cell.cardDescription.text = data[section]![row][2]
        
        cell.cardLocation.text = data[section]![row][3]
        
        let imagePath = data[section]![row][4]
        if imagePath != "" {
            cell.speakerPic.image = UIImage(named: imagePath)?.withRenderingMode(.alwaysOriginal)
            cell.speakerPic.isHidden = false
        }
        
        if data[section]![row][0] == "talk" {
            cell.card.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
            
        } else if data[section]![row][0] == "info" {
            cell.card.backgroundColor = UIColor.tertiary.withAlphaComponent(0.5)
        }
        
        return cell
    }
    
}
