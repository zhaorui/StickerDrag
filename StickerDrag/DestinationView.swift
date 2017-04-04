/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import Cocoa

protocol DestinationViewDelegate {
  func processImageURLs(_ urls: [URL], center: NSPoint)
  func processImage(_ image: NSImage, center: NSPoint)
  func processAction(_ action: String, center: NSPoint)
}

class DestinationView: NSView {
  
  enum Appearance {
    static let lineWidth: CGFloat = 10.0
  }
  
  var delegate: DestinationViewDelegate?
  
  override func awakeFromNib() {
    setup()
  }
  
  
  // MARK: - defines a set with the supported types
  var nonURLTypes : Set<String> {return [String(kUTTypeTIFF)]}
  var acceptableTypes : Set<String> {return nonURLTypes.union([NSURLPboardType])}
  
  func setup() {
    register(forDraggedTypes: Array(acceptableTypes))
  }
  
  //MARK: -
  //we override hitTest so that this view which sits at the top of the view hierachy
  //appears transparent to mouse clicks
  override func hitTest(_ aPoint: NSPoint) -> NSView? {
    return nil
  }
  
  // MARK: - analyze the dragging session data
  //1.
  let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]
  
  func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
    var canAccept = false
    
    //2.
    let pasteBoard = draggingInfo.draggingPasteboard()
    
    //3.
    if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
      canAccept = true
    } else if let types = pasteBoard.types, nonURLTypes.intersection(types).count > 0 {
      canAccept = true
    }
    return canAccept
  }
  
  //MARK: -
  override func draw(_ dirtyRect: NSRect) {
    if isReceivingDrag {
      NSColor.selectedControlColor.set()
      
      let path = NSBezierPath(rect: bounds)
      path.lineWidth = Appearance.lineWidth
      path.stroke()
    }
  }
  
  // MARK: - use NSDraggingInfo  by override draggingEntered(_:)
  //1.
  var isReceivingDrag = false {
    didSet {
      needsDisplay = true
    }
  }
  
  //2.
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    let allow = shouldAllowDrag(sender)
    isReceivingDrag = allow
    return allow ? .copy : NSDragOperation()
  }
  
  // Handling an Exit
  override func draggingExited(_ sender: NSDraggingInfo?) {
    isReceivingDrag = false
  }
  
  //MARK: - Wrap up the Drag
  override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
    let allow = shouldAllowDrag(sender)
    return allow
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    //1.
    isReceivingDrag = false
    let pasteBoard = sender.draggingPasteboard()
    
    //2.
    let point = convert(sender.draggingLocation(), from: nil)
    
    //3.
    if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL],urls.count > 0 {
      delegate?.processImageURLs(urls, center: point)
      return true
    } else if let image = NSImage(pasteboard: pasteBoard) {
      delegate?.processImage(image, center: point)
      return true
    }
    return false
  }
  
}
