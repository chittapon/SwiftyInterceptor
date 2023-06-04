//
//  ViewController.swift
//  SwiftyInterceptor
//
//  Created by Chittapon Thongchim on 06/04/2023.
//  Copyright (c) 2023 Chittapon Thongchim. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
    }
    
    func getPosts() {
        let request = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.handleResponse(data: data)
        }.resume()
    }
    
    func handleResponse(data: Data?) {
        guard let posts: [Post] = data?.decode() else { return }
        DispatchQueue.main.async {
            self.display(posts: posts)
        }
    }
    
    func display(posts: [Post]) {
        self.posts = posts
        tableView.reloadData()
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let vc = DetailViewController()
        vc.post = post
        navigationController?.pushViewController(vc, animated: true)
    }
}


class DetailViewController: UIViewController {
    
    var post: Post!
    let textView = UITextView()
    
    override func loadView() {
        super.loadView()
        view = textView
        textView.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = post.title
        textView.text = post.body
    }
}

extension Data {
    func decode<T: Decodable>(type: T.Type = T.self) -> T? {
        return try? JSONDecoder().decode(type, from: self)
    }
}

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    
    static func mock() -> [Post] {
        return (1...4).map { index in
            Post(id: index, title: "post \(index)", body: "detail \(index)")
        }
    }
}

