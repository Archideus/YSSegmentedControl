//
//  YSSegmentedControl.swift
//  yemeksepeti
//
//  Created by Cem Olcay on 22/04/15.
//  Copyright (c) 2015 yemeksepeti. All rights reserved.
//

import UIKit

// MARK: - Appearance

public struct YSSegmentedControlAppearance {
    public var backgroundColor: UIColor
    public var selectedBackgroundColor: UIColor
    public var textColor: UIColor
    public var font: UIFont
    public var selectedTextColor: UIColor
    public var selectedFont: UIFont
    public var bottomLineColor: UIColor
    public var selectorColor: UIColor
    public var bottomLineHeight: CGFloat
    public var selectorHeight: CGFloat
    public var labelTopPadding: CGFloat
}

// MARK: - Control Item

typealias YSSegmentedControlItemAction = (_ item: YSSegmentedControlItem) -> Void

class YSSegmentedControlItem: UIControl {
    
    // MARK: Properties
    
    private var willPress: YSSegmentedControlItemAction?
    private var didPress: YSSegmentedControlItemAction?
    var label: UILabel!
    
    // MARK: Init
    
    init(frame: CGRect,
         text: String,
         appearance: YSSegmentedControlAppearance,
         willPress: YSSegmentedControlItemAction?,
         didPress: YSSegmentedControlItemAction?) {
        super.init(frame: frame)
        self.willPress = willPress
        self.didPress = didPress
        
        commonInit()
        label.textColor = appearance.textColor
        label.font = appearance.font
        label.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        let views: [String: Any] = ["label": label]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views))
    }
    
    // MARK: Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        willPress?(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didPress?(self)
    }
}


// MARK: - Control

@available(iOS 8.2, *)
public protocol YSSegmentedControlDelegate: class {
    func segmentedControl(_ segmentedControl: YSSegmentedControl, willPressItemAt index: Int)
    func segmentedControl(_ segmentedControl: YSSegmentedControl, didPressItemAt index: Int)
}

@available(iOS 8.2, *)
public typealias YSSegmentedControlAction = (_ segmentedControl: YSSegmentedControl, _ index: Int) -> Void

@available(iOS 8.2, *)
public class YSSegmentedControl: UIView {
    
    // MARK: Properties
    
    weak var delegate: YSSegmentedControlDelegate?
    public var action: YSSegmentedControlAction?
    
    public var appearance: YSSegmentedControlAppearance! {
        didSet {
            self.draw()
        }
    }
    
    public var titles: [String]! {
        didSet {
            if appearance == nil {
                defaultAppearance()
            }
            else {
                self.draw()
            }
        }
    }
    
    var items = [YSSegmentedControlItem]()
    var selector = UIView()
    var bottomLine = CALayer()
    
    // MARK: Init
    
    public init (frame: CGRect, titles: [String], action: YSSegmentedControlAction? = nil) {
        super.init (frame: frame)
        self.action = action
        self.titles = titles
        defaultAppearance()
    }
    
    required public init? (coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
    }
    
    // MARK: Draw
    
    private func reset() {
        for sub in subviews {
            let v = sub
            v.removeFromSuperview()
        }
        
        items.removeAll()
    }
    
    private func draw() {
        reset()
        backgroundColor = appearance.backgroundColor
        for title in titles {
            let item = YSSegmentedControlItem(
                frame: .zero,
                text: title,
                appearance: appearance,
                willPress: { [weak self] segmentedControlItem in
                    guard let weakSelf = self else {
                        return
                    }
                    
                    let index = weakSelf.items.index(of: segmentedControlItem)!
                    weakSelf.delegate?.segmentedControl(weakSelf, willPressItemAt: index)
                },
                didPress: { [weak self] segmentedControlItem in
                    guard let weakSelf = self else {
                        return
                    }
                    
                    let index = weakSelf.items.index(of: segmentedControlItem)!
                    weakSelf.selectItem(at: index, withAnimation: true)
                    weakSelf.action?(weakSelf, index)
                    weakSelf.delegate?.segmentedControl(weakSelf, didPressItemAt: index)
            })
            addSubview(item)
            items.append(item)
        }
        // bottom line
        bottomLine.backgroundColor = appearance.bottomLineColor.cgColor
        layer.addSublayer(bottomLine)
        // selector
        selector.backgroundColor = appearance.selectorColor
        addSubview(selector)
        
        selectItem(at: 0, withAnimation: true)
        
        setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = frame.size.width / CGFloat(titles.count)
        var currentX: CGFloat = 0
        
        for item in items {
            item.frame = CGRect(
                x: currentX,
                y: appearance.labelTopPadding,
                width: width,
                height: frame.size.height - appearance.labelTopPadding)
            currentX += width
        }
        
        bottomLine.frame = CGRect(
            x: 0,
            y: frame.size.height - appearance.bottomLineHeight,
            width: frame.size.width,
            height: appearance.bottomLineHeight)
        
        selector.frame = CGRect (
            x: selector.frame.origin.x,
            y: frame.size.height - appearance.selectorHeight,
            width: width,
            height: appearance.selectorHeight)
    }
    
    @available(iOS 8.2, *)
    private func defaultAppearance() {
        appearance = YSSegmentedControlAppearance(
            backgroundColor: .clear,
            selectedBackgroundColor: .clear,
            textColor: UIColor(red: 0.61, green: 0.64, blue: 0.67, alpha: 1.00),
            font: .systemFont(ofSize: 15, weight: UIFontWeightRegular),
            selectedTextColor: UIColor(red: 0.15, green: 0.71, blue: 0.63, alpha: 1.00),
            selectedFont: .systemFont(ofSize: 15, weight: UIFontWeightSemibold),
            bottomLineColor: UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.00),
            selectorColor: UIColor(red: 0.15, green: 0.71, blue: 0.63, alpha: 1.00),
            bottomLineHeight: 0.5,
            selectorHeight: 2,
            labelTopPadding: 0)
    }
    
    // MARK: Select
    
    public func selectItem(at index: Int, withAnimation animation: Bool) {
        moveSelector(at: index, withAnimation: animation)
        for item in items {
            if item == items[index] {
                item.label.textColor = appearance.selectedTextColor
                item.label.font = appearance.selectedFont
                item.backgroundColor = appearance.selectedBackgroundColor
            } else {
                item.label.textColor = appearance.textColor
                item.label.font = appearance.font
                item.backgroundColor = appearance.backgroundColor
            }
        }
    }
    
    private func moveSelector(at index: Int, withAnimation animation: Bool) {
        let width = frame.size.width / CGFloat(items.count)
        let target = width * CGFloat(index)
        UIView.animate(withDuration: animation ? 0.2 : 0,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                        [unowned self] in
                        self.selector.frame.origin.x = target
            },
                       completion: nil)
    }
}
