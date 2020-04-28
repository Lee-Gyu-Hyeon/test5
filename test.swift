import UIKit
import Alamofire
import Kingfisher

class SixthViewController: UITableViewController, SlidingContainerViewControllerDelegate {

    //
    let cellId = "cellId"
    
    //전역변수 설정
    var no: [String] = []
    var scope: [String] = []
    var title1 : [String] = []
    var dancefile: [String] = []
    var creator: [String] = []
    var text: [String] = []
    var numberoflike: [String] = []
    var checklike: [String] = []
    var downloadedData: [String] = []
    
    //
    var deletePlanetIndexPath: NSIndexPath? = nil
    
    //
    var noDataLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        //
        navigationItem.title = "내앨범"
        navigationController?.navigationBar.isTranslucent = false
        
        //
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .plain, target: self, action: #selector(handleMenu))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        //
        tableView.register(MyAlbumCell.self, forCellReuseIdentifier: cellId)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorInset.left = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.rowHeight = UITableView.automaticDimension
        
        initRefresh()
//---------------------------------------------------------------------------------------------------------------------------------------
//Rest API URL 요청
//---------------------------------------------------------------------------------------------------------------------------------------
        let _url = "http://www.appboomclap.co.kr:8080/BoomClap/Main"
        let parameters: Parameters = [
            "user_id": UserDefaults.standard.string(forKey: "loginID")!,
            "user_no": UserDefaults.standard.string(forKey: "userno")!,
            "protocol": NetworkProtocol().GET_USER_VLIST_REQ,
        ]
        Alamofire.request(_url, method: .post, parameters: parameters).responseJSON { response in
            if response.result.value != nil {

            }

            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                let utf8text = "\(utf8Text)"
                var cnt = 0
                var array : [String] = ["a","b","c","d","e","f","g","h"]


                //
                for utf8text in utf8text.components(separatedBy: .newlines) {
                    array[cnt] = utf8text
                    cnt += 1
                }


                //
                let c = array[2].split {$0 == "$"}.map(String.init)

                for i in 0..<c.count {
                    self.downloadedData = c[i].split {$0 == "#"}.map(String.init)
                    self.no.append(self.downloadedData[0])
                    self.scope.append(self.downloadedData[1])
                    self.title1.append(self.downloadedData[2])
                    self.dancefile.append(self.downloadedData[3])
                    self.creator.append(self.downloadedData[4])
                    self.text.append(self.downloadedData[5])
                    self.numberoflike.append(self.downloadedData[6])
                    self.checklike.append(self.downloadedData[7])
                }
            }
            self.tableView.reloadData()
            self.tableView.delegate = self
        }
//---------------------------------------------------------------------------------------------------------------------------------------
    }
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
//좌측 네비게이션 메뉴 클릭 이벤트
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func handleMenu() { SidebarLauncher.init(delegate: self).show() }
//---------------------------------------------------------------------------------------------------------------------------------------
    
//---------------------------------------------------------------------------------------------------------------------------------------
//우측 네비게이션 메뉴 클릭 이벤트
//---------------------------------------------------------------------------------------------------------------------------------------
    //@objc func didSelect(_ sender: UIButton) { }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
    //TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dancefile.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MyAlbumCell
        
        DispatchQueue.main.async {
            let imageValue = self.dancefile[indexPath.row]
            let imageValueEn = (imageValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))!
            let imageURL = "https://boomclap-ruyi.s3.ap-northeast-2.amazonaws.com/user/\(UserDefaults.standard.string(forKey: "userno")!)/thumbnail/\(imageValue)_thumbnail.jpg"
            let url : URL! = URL(string: imageURL)
            //print("이미지 주소(내앨범):", imageURL)
            
            cell.productImage.kf.setImage(with: url)
            cell.productNameLabel.text = self.no[indexPath.row]
            cell.productDescriptionLabel.text = self.title1[indexPath.row]
            cell.productSubTitle.text = self.creator[indexPath.row]
            
            print("--------------------------------------------------------")
            print("사용자 번호:", imageValueEn)
            print("이미지 주소(내앨범):", imageURL)
            print("제목:", self.no[indexPath.row])
            print("부제목:", self.title1[indexPath.row])
            print("업로드일", self.creator[indexPath.row])
            print("점수:", self.text[indexPath.row])
            print("--------------------------------------------------------")
        }
        return cell
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: Int = 0

        if self.dancefile.count > 0 {
            self.tableView.backgroundView = nil
            numOfSection = 1
            noDataLabel.isHidden = true

        } else {
            //let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)
            noDataLabel.text = "No Data Available"
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            //self.tableView.backgroundView = noDataLabel
            self.view.addSubview(noDataLabel)
        }
        return numOfSection
    }

    //
    func slidingContainerViewControllerDidMoveToViewController(_ slidingContainerViewController: SlidingContainerViewController, viewController: UIViewController, atIndex: Int) {}
    func slidingContainerViewControllerDidShowSliderView(_ slidingContainerViewController: SlidingContainerViewController) {}
    func slidingContainerViewControllerDidHideSliderView(_ slidingContainerViewController: SlidingContainerViewController) {}
    
    func initRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "새로고침 중입니다...")
        
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
            
        } else {
            tableView.addSubview(refresh)
            
        }
    }
    
    @objc func updateUI(refresh: UIRefreshControl) {
        refresh.endRefreshing()
        tableView.reloadData()
    }
}



extension SixthViewController: SidebarDelegate{
    func sidbarDidOpen() {

    }

    func sidebarDidClose(with item: NavigationModel?) {
        guard let item = item else {return}
        switch item.type {
            
        //
        case .홈:
            print("홈")
            let vc = TabBarViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        //
        case .사용자:
            print("사용자")
            let alert = UIAlertController(title: "서비스 준비중입니다.", message: "", preferredStyle: .alert)

            let okaction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){ (action: UIAlertAction) -> Void in
            }

            alert.addAction(okaction)

            self.present(alert, animated: true)
        //
        case .메이킹:
            print("메이킹")
            let alert = UIAlertController(title: "서비스 준비중입니다.", message: "", preferredStyle: .alert)

            let okaction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){ (action: UIAlertAction) -> Void in
            }

            alert.addAction(okaction)

            self.present(alert, animated: true)
        //
        case .내앨범:
            print("내앨범")
            let vc = SixthViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        //
        case .로그아웃:
            print("로그아웃")
            break
        }
    }
}




extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
