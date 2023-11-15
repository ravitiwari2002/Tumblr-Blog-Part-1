import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    
    let refreshControl = UIRefreshControl()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell

        let post = blogPosts[indexPath.row]

        // Check if the post has photos
        if let photo = post.photos.first {
            let url = photo.originalSize.url
            
            Nuke.loadImage(with: url, into: cell.posterImageView)
        }

        // Set the text on the labels
       
        cell.overviewLabel.text = post.summary

        return cell
    }
    
    private var blogPosts: [Post] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)

        
        fetchPosts()
    }
    
    @objc func refreshPosts() {
        
        fetchPosts()
        refreshControl.endRefreshing()
    }



    
    func fetchPosts() {
       
       let url = URL(string: "https://api.tumblr.com/v2/blog/yeahwriteme.tumblr.com/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        
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
                    guard let self = self else { return }
                    self.blogPosts = blog.response.posts
                    self.tableView.reloadData()
                    let posts = blog.response.posts
                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    refreshControl.endRefreshing()
                }
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
