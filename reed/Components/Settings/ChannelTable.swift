//
//  ChannelTable.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import AppKit
import SwiftUI

class ChannelNSTableView: NSTableView {
    // Define your NSTableView subclass as you would in an AppKit app
}

class ChannelNSTableController: NSViewController {
    @IBOutlet var tableView: ChannelNSTableView!
    
    var data: [Channel] = []
    
    func refresh(channels: [Channel]) {
        data = channels
    }
    
}

extension ChannelNSTableController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
      return (data.count)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
      let channel = data[row]
      
      guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        cell.textField?.stringValue = channel.title!
      return cell
    }
  }

struct ChannelNSTable: NSViewControllerRepresentable {

    @Binding var channels: Array<Channel>?

    typealias NSViewControllerType = ChannelNSTableController

    func makeNSViewController(
        context: NSViewControllerRepresentableContext<ChannelNSTable>
    ) -> ChannelNSTableController {
        return ChannelNSTableController()
    }

    func updateNSViewController(
        _ nsViewController: ChannelNSTableController,
        context: NSViewControllerRepresentableContext<ChannelNSTable>
    ) {

        if let channels = channels {
            nsViewController.refresh(channels: channels)
        }

        return

    }

}
