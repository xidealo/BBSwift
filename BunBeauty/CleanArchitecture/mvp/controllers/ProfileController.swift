//
//  Profile.swift
//  BunBeauty
//
//  Created by Марк Шавловский on 09/07/2019.
//  Copyright © 2019 BunBeauty. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher
class ProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var cityTex: UILabel!
    @IBOutlet weak var phoneText: UILabel!
    @IBOutlet weak var serviceTableView: UITableView!
    @IBOutlet weak var avatarProfileImageView: UIImageView!
    
    @IBOutlet weak var subscriptionsProfileBtn: UIButton!
    var user:User?
    
    //var profileUserInteractor:ProfileUserInteractor  = ProfileUserInteractor()
    var profilePresenter:ProfilePresenter?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(user != nil){
            setProfileData(user: user!)
        }else{
            //get byId
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
   
    }
    
    private func  setProfileData(user:User) -> Void {
        nameText.text = user.name
        cityTex.text = user.city
        phoneText.text = user.phone
        avatarProfileImageView.kf.setImage(with: URL(string: user.photoLink))
        
        //updateServiceList()!
    }
    
    func updateServiceList(ownerId:String) -> Void {
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = serviceTableView.dequeueReusableCell(withIdentifier: "serviceIdCell")!
        //cell.textLabel?.text = serviceList[indexPath.row].getName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func goToSubscriptions(_ sender: Any) {
        
    }
    
    @IBAction func goToMainScreen(_ sender: Any) {
        let  mainScreen = storyboard?.instantiateViewController(withIdentifier: "MainScreen") as! MainScreen
        navigationController?.pushViewController(mainScreen, animated: true)
    }
    
    @IBAction func goToAdditionService(_ sender: Any) {
        let  additionServiceVC = storyboard?.instantiateViewController(withIdentifier: "AdditionService") as! CreationServiceController
        navigationController?.pushViewController(additionServiceVC, animated: true)
    }
    
    func goToGuestService(serviceId:String) {
        let  guestService = storyboard?.instantiateViewController(withIdentifier: "GuestService") as! GuestService
        guestService.serviceId = serviceId
        navigationController?.pushViewController(guestService, animated: true)
    }
    
    
}
