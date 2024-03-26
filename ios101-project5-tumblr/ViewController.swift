//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🍏 numberOfRowsInSection called with movies count: \(posts.count)")
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        if let photo = post.photos.first {
            let url = photo.originalSize.url
                  
                Nuke.loadImage(with: url, into: cell.postImageView)
            }

            cell.summaryLabel.text = post.summary

            return cell
        
        
    }
    
    private let refreshControl = UIRefreshControl()
    

    @IBOutlet weak var tableView: UITableView!
    
    private var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        if #available(iOS 10.0, *) {
               tableView.refreshControl = refreshControl
           } else {
               tableView.addSubview(refreshControl)
           }

           refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
           

        
        fetchPosts()
    }

    @objc private func refreshData(_ sender: Any) {
        print("🔄 Starting to refresh data...")
        
        refreshControl.beginRefreshing()
        fetchPosts()
    }


    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/nationalgeographicmagazine.tumblr.com/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    
                    self?.posts = posts
                    self?.tableView.reloadData()
                    self?.refreshControl.endRefreshing()
                    print("🍏 Fetched and stored \(posts.count) movies")
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
