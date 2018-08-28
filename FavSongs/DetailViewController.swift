/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2018B
 Assessment: Assignment
 Author: Duong Huu Khang
 ID: s3635116
 Created date: 15/08/2018
 Acknowledgement:
 https://stackoverflow.com/questions/33430270/on-click-on-label-go-to-next-page
 */

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let song = detailItem {
            if let img = imageView {
                img.image = UIImage(data: song.image!)
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                img.addGestureRecognizer(gestureRecognizer)
            }
            if let label = titleLabel {
                label.text = "Title: " + song.title!
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
                label.addGestureRecognizer(gestureRecognizer)
            }
            if let label = artistLabel {
                label.text = "Artist: " + song.artist!
            }
            if let label = yearLabel {
                label.text = "Year: " + String(song.year)
            }
        }
    }
    
    // open the url in safari if available when the user tap the image or title
    @objc func imageTapped(sender: UIGestureRecognizer) {
        let urlStr = detailItem?.url
        if urlStr != nil && urlStr != ""{
            let string = urlStr!
            let url: URL
            if string.starts(with: "http://") || string.starts(with: "https://") {
                url = URL(string: string)!
            } else {
                url = URL(string: "http://" + string)!
            }
            UIApplication.shared.open(url, options: ["":""], completionHandler: nil)
        }
    }
    
    @objc func titleTapped(sender: UIGestureRecognizer) {
        let urlStr = detailItem?.url
        if urlStr != nil && urlStr != ""{
            let string = urlStr!
            let url: URL
            if string.starts(with: "http://") || string.starts(with: "https://") {
                url = URL(string: string)!
            } else {
                url = URL(string: "http://" + string)!
            }
            UIApplication.shared.open(url, options: ["":""], completionHandler: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Song? {
        didSet {
            // Update the view.
            configureView()
        }
    }

}

