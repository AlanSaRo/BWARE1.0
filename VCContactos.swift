//
//  VCContactos.swift
//  Bware
//
//  Created by Alan Joseph Salazar Romero on 22/11/17.
//  Copyright © 2017 Alan Salazar. All rights reserved.
//

import UIKit
import ContactsUI

class VCContactos: UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var tablaContactos: UITableView!

    var arregloContactos = [CNContact]()    // En este arreglo se guardan los contactos, para ponerlos en el table view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Atrás", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton

        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(iniciar), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(terminar), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Llama a la funcion de los contactos desde un boton
    @IBAction func agregarContacto(_ sender: Any) {
        showContactsPicker()
    }
    
    //Funcion para acceder a los contactos
    func showContactsPicker(){
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self;
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true) {
            
            
        }
    }
    

    
    // Esta funcion selecciona un contacto para agregarlo a la lista de contactos de emergencia.
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {

        self.perform(#selector(agregarContacto2(_:)), with: contact, afterDelay: 1)

    }
    
    
    @objc func agregarContacto2(_ contact: CNContact) {
        //arregloContactos.append(contact)
        var flag: Bool = true
        
        for contacto in arregloContactos{
            if(contacto.familyName == contact.familyName && flag == true){
                if(contacto.givenName != contact.givenName){
                    flag = true
                }
                else{
                    flag = false
                }
            }else if(contacto.familyName != contact.familyName && flag == true){
                flag = true
            }else{
                flag = false
            }
        }
        
        if flag{
            arregloContactos.append(contact)
        }
        
        tablaContactos.reloadData()
    }
    
    
    // Metodos para poblar las tablas __________________________________________________________
    
    
    // Para el numero de hileras en el table view
    func numberOfSectionsInTableView(tableView:UITableView)->Int{
        return 1
    }
    
    
    // Para el tamaño del table view (Este tamaño deberá variar en cuestión del numero de contactos seleccionados)
    func tableView(_ tableView:UITableView,numberOfRowsInSection section:Int)->Int{
        return arregloContactos.count
    }
    
    
    // Para cambiar el contenido de la tabla
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell{
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaContactos",for: indexPath)
        if(arregloContactos.count != 0){
            celda.textLabel?.text = arregloContactos[indexPath.row].givenName + " " + arregloContactos[indexPath.row].familyName  // Agrega en la primera celda el nombre del contacto
            celda.detailTextLabel?.text = ((arregloContactos[indexPath.row].phoneNumbers[0].value ).value(forKey: "digits") as! String)
        }
        
        return celda
    }
    // ----------------------------------------------------------------------------------------------
    
    // Para realizar una llamada cuando se da click a un contacto______________________________________________
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaContactos",for: indexPath)
        
        let url: NSURL = URL(string: ((arregloContactos[indexPath.row].phoneNumbers[0].value ).value(forKey: "digits") as! String))! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)

        
        if let url = NSURL(string: "tel://\(((arregloContactos[indexPath.row].phoneNumbers[0].value ).value(forKey: "digits") as! String))"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
        
    }
    // ----------------------------------------------------------------------------------------------
    
    // Métodos para sobreescribir los user defaults  ____________________________________________
    
    
    @objc func iniciar()
    {
        print("Entrando")
        let preferencias = UserDefaults.standard
        
        preferencias.synchronize()
        
        let decoded = UserDefaults.standard.object(forKey: "listaContactos") as? Data
        
        if(decoded != nil){
            let arregloContactosGuardados = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [CNContact]
            
            arregloContactos = arregloContactosGuardados
            /*
             if arregloContactos.count > 0 {
             print("\n(arregloContactos.count)\n\(arregloContactos[0].givenName)")
             }
             */
            tablaContactos.reloadData()
        }
    }
    
    
    @objc func terminar()
    {
        print("Saliendo")
        let preferencias = UserDefaults.standard
        
        let encodeData = NSKeyedArchiver.archivedData(withRootObject: arregloContactos)
        preferencias.set(encodeData, forKey: "listaContactos")
        
        
        preferencias.synchronize()
    }
    
    
    //___________________________________________________________________________________________

    // ---------------------------------------------- PREFERENCIAS ------------------------------
    
    
    override func viewDidAppear(_ animated: Bool) {
        //print("Entrando")
        let preferencias = UserDefaults.standard
        preferencias.synchronize()
        let decoded = UserDefaults.standard.object(forKey: "listaContactos") as? Data
        if(decoded != nil){
            let arregloContactosGuardados = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [CNContact]
            arregloContactos = arregloContactosGuardados
            /*
             if arregloContactos.count > 0 {
             print("\n(arregloContactos.count)\n\(arregloContactos[0].givenName)")
             }
             */
            tablaContactos.reloadData()
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("Saliendo")
        let preferencias = UserDefaults.standard
        
        let encodeData = NSKeyedArchiver.archivedData(withRootObject: arregloContactos)
        preferencias.set(encodeData, forKey: "listaContactos")
        
        
        preferencias.synchronize()
    }
    // ----------------------------------------------------------------------------------------------
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
