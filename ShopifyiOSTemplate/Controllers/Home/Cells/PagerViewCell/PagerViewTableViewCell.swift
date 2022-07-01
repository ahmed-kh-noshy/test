//
//  PagerViewTableViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 13/11/21.
//

import UIKit
import FSPagerView

protocol PagerViewTableViewCellDelegate: AnyObject {
    func pagerClickAction(collectionID: String, listTitle: String?)
}

class PagerViewTableViewCell: UITableViewCell {

    
    fileprivate var pagerViews: [BannerConfig]? = []
    weak var delegate: PagerViewTableViewCellDelegate?
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = self.pagerViews?.count ?? 0
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.pageControl.hidesForSinglePage = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(pagerViews: [BannerConfig]?) {
        self.pagerViews = pagerViews
        self.pageControl.numberOfPages = pagerViews?.count ?? 0
        self.pagerView.reloadData()
    }
}

extension PagerViewTableViewCell: FSPagerViewDataSource,FSPagerViewDelegate {
    
    // MARK:- FSPagerViewDataSource
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return pagerViews?.count ?? 0
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.image = nil
        let bannerConfig = pagerViews?[index]
        if let imageURL = bannerConfig?.imageURL, let url = URL(string: imageURL) {
            cell.imageView?.setImageFrom(url)
        } else if let localImageName = bannerConfig?.localImageName, let bannerImage = UIImage(named: localImageName) {
            cell.imageView?.image = bannerImage
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        delegate?.pagerClickAction(collectionID: pagerViews?[index].collectionID ?? "", listTitle: pagerViews?[index].title)
    }
    
    // MARK:- FSPagerViewDelegate
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
}
