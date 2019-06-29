//
//  CompanyCardViewController.swift
//  CompanyProject
//
//  Created by Master on 28/06/2019.
//  Copyright © 2019 Kirirushi. All rights reserved.
//

import UIKit
struct Company: Codable {
  var id: String
  var name: String
  var description: String
}
class CompanyCardViewController: UIViewController {
  var id: String?
  weak var companyTableView: UITableView?

  var company: Company?

  override func viewDidLoad() {
    super.viewDidLoad()

    let tempTableView = UITableView()
    tempTableView.backgroundColor = .white
    tempTableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tempTableView)
    view.bringSubviewToFront(tempTableView)
    companyTableView = tempTableView
    let constraints = [
      NSLayoutConstraint(item: tempTableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tempTableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tempTableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tempTableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
    ]
    NSLayoutConstraint.activate(constraints)
    companyTableView?.delegate = self
    companyTableView?.dataSource = self
    companyTableView?.allowsSelection = false
    companyTableView?.separatorColor = .clear
    requestCompany()
  }

  func requestCompany() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    guard let id = id, let companyRequestURL = URL(string: "http://megakohz.bget.ru/test.php?id=\(id)") else {
      dismiss(animated: true)
      return
    }
    company = nil
    URLSession(configuration: .default).dataTask(with: companyRequestURL) { (data, _, error) in
      DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
      if let error = error {
        let alertController = UIAlertController(title: "Ошибка", message: "Код ошибки \(error.localizedDescription)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ in
          self.navigationController?.popViewController(animated: true)
        }))
        DispatchQueue.main.async {
          self.present(alertController, animated: true)
        }
      }
      if let data = data {
        do {
          let company = try JSONDecoder().decode([Company].self, from: data)
          DispatchQueue.main.async {
            self.company = company.first
            self.companyTableView?.reloadData()
          }
        } catch {
          let alertController = UIAlertController(title: "Ошибка", message: "Невозможно разобрать ответ от сервера", preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "ОК", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
          }))
          DispatchQueue.main.async {
            self.present(alertController, animated: true)
          }
        }
      }
    }.resume()
  }
}
extension CompanyCardViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return company == nil ? 0 : 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "companyCell") {
      cell.textLabel?.text = company?.name
      cell.detailTextLabel?.numberOfLines = 0
      cell.detailTextLabel?.text = company?.description
      return cell
    } else {
      let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "companyCell")
      cell.textLabel?.text = company?.name
      cell.detailTextLabel?.numberOfLines = 0
      cell.detailTextLabel?.text = company?.description
      return cell
    }
  }
}
