//
//  MyCalendar.swift
//  BunBeauty
//
//  Created by Марк Шавловский on 29/07/2019.
//  Copyright © 2019 BunBeauty. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
class MyCalendar: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    private let WEEKS_COUNT = 4
    private let DAYS_COUNT = 7
    private let WORKER = "worker"
    private let USER = "user"
    
    var serviceId:String!
    var statusUser:String!
    
    private var selectedDay:String!
    private var indexDate = 0
    private var dates = [String]()
    private var worker:Worker!
    private var userId:String!
    
    @IBOutlet weak var calendarCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dates = generateDates(startDate: Date(), addbyUnit: Calendar.Component.day, value: 28)
        userId = getUserId()
        //если статус воркер if status == worker
        if statusUser == WORKER{
            worker = Worker(userId:userId,serviceId: serviceId)
        }
    }
    //create calendar
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 7
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size+10)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WEEKS_COUNT*DAYS_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = calendarCollection.dequeueReusableCell(withReuseIdentifier: "dayIdCell", for: indexPath) as! DayCell
        cell = setDefaultCell(cell: cell) as! DayCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let curDate = dateFormatter.date(from: dates[indexDate])!
        cell.dayText.text = WorkWithTimeApi.getDateInFormatDM(date: curDate)
        if statusUser == WORKER{
            //select day for worker
            let dayId = WorkWithLocalStorageApi.checkCurrentDay(date: dates[indexDate], serviceId: serviceId)
            if dayId != nil{
                if WorkWithLocalStorageApi.hasSomeWork(dayId: dayId!) {
                    cell.dayText.textColor = UIColor.blue
                }
            }
        }else{
            //checkOrder
            cell = checkOrder(dateYMD: WorkWithTimeApi.getDateInFormatYMD(date: curDate), cell: cell) as! DayCell
        }
        indexDate += 1
        return cell
    }
    private func checkOrder(dateYMD:String, cell:UICollectionViewCell) -> UICollectionViewCell {
        let date = getOrderDate()
        
        if date != nil {
            
        }else{
            let dayId = WorkWithLocalStorageApi.checkCurrentDay(date: dateYMD, serviceId: serviceId)
            if dayId == nil{
                //enable false
                return noEnableCell(cell: cell)
            }else{
                /*if !hasSomeTime(dayId: dayId!){
                    //enable false
                    return noEnableCell(cell: cell)
                }*/
            }
        }
        return cell
    }
    
    private func noEnableCell(cell:UICollectionViewCell) -> UICollectionViewCell {
        let curCell = cell as! DayCell
        curCell.isUserInteractionEnabled = false
        curCell.dayText.isEnabled = false
        return curCell
    }
    private func setDefaultCell(cell:UICollectionViewCell) -> UICollectionViewCell {
        let curCell = cell as! DayCell
        curCell.layer.backgroundColor = UIColor.white.cgColor
        curCell.dayText.textColor = UIColor.black
        curCell.isUserInteractionEnabled = true
        curCell.dayText.isEnabled = true
        return curCell
    }
    func getOrderDate() -> String? {
       // let realm = DBHelper().getDBhelper()
        //let ordersCursor = realm.objects(TABLE_ORDERS.self).filter("KEY_ID = %@", userId)
        
        //for orderCursor in ordersCursor{
            
        //}
        return nil
    }
    
    func hasSomeTime(dayId:String) -> Bool {
        return false
    }
    //select day
    var selectedIndexPath: IndexPath?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DayCell
        cell.layer.backgroundColor = UIColor.yellow.cgColor
        let curSelectedDay = cell.dayText.text
        if(selectedDay == curSelectedDay){
            //нажали на тот же день
            cell.layer.backgroundColor = UIColor.white.cgColor
            self.selectedIndexPath = nil
            selectedDay = nil;
        }
        else{
            selectedDay = curSelectedDay?.replacingOccurrences(of: "\n", with: "-")
            let splitedDate = selectedDay.components(separatedBy: "-")
            let numberMonth = WorkWithTimeApi.monthToNumber(month: splitedDate[1])
            let monthAndDay = numberMonth + "-" + splitedDate[0]
            
            for date in dates{
                if(date.contains(monthAndDay)){
                    selectedDay = date
                }
            }
        }
        self.selectedIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = calendarCollection.cellForItem(at: indexPath)
        
        cell!.layer.backgroundColor = UIColor.white.cgColor
        
        self.selectedIndexPath = nil
    }
    
    func generateDates(startDate :Date?, addbyUnit:Calendar.Component, value : Int) -> [String] {
        var dates = [String]()
        var date = startDate!
        let endDate = Calendar.current.date(byAdding: addbyUnit, value: value, to: date)!
        while date < endDate {
            date = Calendar.current.date(byAdding: addbyUnit, value: 1, to: date)!
            let nDate = WorkWithTimeApi.getDateInFormatYMD(date: date)
            dates.append(nDate)
        }
        return dates
    }
    
    override func viewWillAppear(_ animated: Bool) {
        indexDate = 0
        selectedDay = nil
        calendarCollection.reloadData()
    }
    private func getUserId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    @IBAction func goToMyTime(_ sender: Any) {
        //day id, status, service id
        if(isDaySelected()){
            if(WorkWithLocalStorageApi.checkCurrentDay(date: selectedDay, serviceId: serviceId) != nil){
                //use date
                goToMyTimeNoBtn(dayId: WorkWithLocalStorageApi.checkCurrentDay(date: selectedDay, serviceId: serviceId)!, _statusUser: statusUser)
            }
            else{
                //add new date
                let dayId = worker.addWorkingDay(date: selectedDay)
                goToMyTimeNoBtn(dayId: dayId, _statusUser: statusUser)
            }
        }
    }
    
    func goToMyTimeNoBtn(dayId:String, _statusUser:String){
        let  myTimeVC = storyboard?.instantiateViewController(withIdentifier: "MyTime") as! MyTime
        myTimeVC.serviceId = serviceId
        myTimeVC.userId = userId
        myTimeVC.workingDaysId = dayId
        myTimeVC.statusUser = _statusUser
        navigationController?.pushViewController(myTimeVC, animated: true)
    }
    func isDaySelected() -> Bool {
        return selectedDay != nil
    }
}
