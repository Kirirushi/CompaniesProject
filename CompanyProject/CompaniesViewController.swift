//
//  ViewController.swift
//  CompanyProject
//
//  Created by Master on 27/06/2019.
//  Copyright © 2019 Kirirushi. All rights reserved.
//

import UIKit

struct CompaniesJSON: Codable {
  var id: String
  var name: String
}
class CompaniesViewController: UIViewController {
  weak var companiesTableView: UITableView?

  var companiesArray: [CompaniesJSON] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    let tempTableView = UITableView()
    tempTableView.backgroundColor = .white
    tempTableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tempTableView)
    view.bringSubviewToFront(tempTableView)
    companiesTableView = tempTableView
    let constraints = [
      NSLayoutConstraint(item: tempTableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tempTableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tempTableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tempTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
    ]
    NSLayoutConstraint.activate(constraints)
    companiesTableView?.delegate = self
    companiesTableView?.dataSource = self
    
    requestCompanies()
  }
  func requestCompanies() {
    companiesArray.removeAll()
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    guard let companiesURL = URL(string: "http://megakohz.bget.ru/test.php") else { return }
    let request = URLRequest(url: companiesURL)
    URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, response, error) in
      DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
      if let error = error {
        let alertController = UIAlertController(title: "Ошибка", message: "Код ошибки \(error.localizedDescription)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .default))
        self.present(alertController, animated: true)
      }
      if let data = data {
        do {
          let companiesArray = try JSONDecoder().decode([CompaniesJSON].self, from: data)
          self.companiesArray = companiesArray
          DispatchQueue.main.async {
            self.companiesTableView?.reloadData()
          }
        } catch {
          let alertController = UIAlertController(title: "Ошибка", message: "Невозможно разобрать ответ от сервера", preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "ОК", style: .default))
          self.present(alertController, animated: true)
        }
      }
    }.resume()
  }
}

extension CompaniesViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return companiesArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let company = companiesArray[indexPath.row]
    if let companyCell = tableView.dequeueReusableCell(withIdentifier: "companyCell") as? CompanyCell {
      companyCell.textLabel?.text = company.name
      companyCell.id = company.id
      return companyCell
    } else {
      let companyCell = CompanyCell(style: .default, reuseIdentifier: "companyCell")
      companyCell.textLabel?.text = companiesArray[indexPath.row].name
      companyCell.id = company.id
      return companyCell
    }
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let companyViewController = CompanyCardViewController()
    companyViewController.title = companiesArray[indexPath.row].name
    companyViewController.id = companiesArray[indexPath.row].id
    navigationController?.pushViewController(companyViewController, animated: true)
  }
}
class CompanyCell: UITableViewCell {
  var id: String?
}
