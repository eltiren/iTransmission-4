//
//  TorrentViewController.swift
//  iTransmission
//
//  Created by Vitalii Yevtushenko on 19.07.2019.
//

import UIKit

@objc
class TorrentViewController: _TorrentViewController {

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? controller.torrentsCount() : 0
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            selectedIndexPaths.add(indexPath)
            let cell = tableView.cellForRow(at: indexPath) as! TorrentCell
            cell.controlButton.isEnabled = false
        } else {
            let storyboard = UIStoryboard(name: "Main_Storyboard", bundle: nil)
            let detailController = storyboard.instantiateViewController(identifier: "detail_view") as! DetailViewController
            let torrent = controller.torrent(at: indexPath.row)
            detailController.setWith(torrent, controller: controller)
            navigationController?.pushViewController(detailController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
