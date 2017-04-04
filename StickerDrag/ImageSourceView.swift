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

class ImageSourceView: RoundedRectView {
  override func mouseDown(with event: NSEvent) {
    //1.
    let pasteboardItem = NSPasteboardItem()
    pasteboardItem.setDataProvider(self, forTypes: [kUTTypeTIFF])
    
    //2.
    let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
    draggingItem.setDraggingFrame(self.bounds, contents: snapshot())
    
    //3.
    beginDraggingSession(with: [draggingItem], event: event, source: self)
  }
}

//MARK: - NSDraggingSrouce
extension ImageSourceView : NSDraggingSource {
  func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
    return .generic
  }
}

extension ImageSourceView : NSPasteboardItemDataProvider {
  func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: String) {
    if let pasteboard = pasteboard, type == String(kUTTypeTIFF), let image = NSImage(named: "unicorn") {
      let finalImage = image.tintedImageWithColor(NSColor.randomColor())
      let tiffdata = finalImage.tiffRepresentation
      pasteboard.setData(tiffdata, forType: type)
    }
    }
}
