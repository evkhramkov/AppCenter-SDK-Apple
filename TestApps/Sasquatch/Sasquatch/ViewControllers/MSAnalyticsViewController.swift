import UIKit

class MSAnalyticsViewController: UITableViewController, AppCenterProtocol {

  @IBOutlet weak var enabled: UISwitch!
  @IBOutlet weak var eventName: UITextField!
  @IBOutlet weak var pageName: UITextField!

  var appCenter: AppCenterDelegate!
  var eventPropertiesSection: EventPropertiesTableSection!
  var targetPropertiesSection: TargetPropertiesTableSection!

  private var kEventPropertiesSectionIndex: Int = 2
  private var kTargetPropertiesSectionIndex: Int = 3

  override func viewDidLoad() {
    targetPropertiesSection = TargetPropertiesTableSection(tableSection: kTargetPropertiesSectionIndex, tableView: tableView)
    eventPropertiesSection = EventPropertiesTableSection(tableSection: kEventPropertiesSectionIndex, tableView: tableView)
    super.viewDidLoad()
    tableView.setEditing(true, animated: false)
    self.enabled.isOn = appCenter.isAnalyticsEnabled()
  }

  @IBAction func trackEvent() {
    guard let name = eventName.text else {
      return
    }
    let eventPropertiesDictionary = eventPropertiesSection.eventPropertiesDictionary()
    appCenter.trackEvent(name, withProperties: eventPropertiesDictionary)
    for targetToken in MSTransmissionTargets.shared.transmissionTargets.keys {
      if MSTransmissionTargets.shared.targetShouldSendAnalyticsEvents(targetToken: targetToken) {
        let target = MSTransmissionTargets.shared.transmissionTargets[targetToken]
        target!.trackEvent(name, withProperties: eventPropertiesDictionary)
      }
    }
  }

  @IBAction func trackPage() {
    guard let name = eventName.text else {
      return
    }
    appCenter.trackPage(name)
  }

  @IBAction func enabledSwitchUpdated(_ sender: UISwitch) {
    appCenter.setAnalyticsEnabled(sender.isOn)
    sender.isOn = appCenter.isAnalyticsEnabled()
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let propertySection = getPropertySection(at: indexPath)
    propertySection?.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if let propertySection = getPropertySection(at: indexPath) {
      return propertySection.tableView(tableView, editingStyleForRowAt: indexPath)
    }
    return .delete
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let propertySection = getPropertySection(at: indexPath)
    if propertySection != nil && propertySection!.isInsertRow(indexPath) {
      self.tableView(tableView, commit: .insert, forRowAt: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let propertySection = getPropertySection(at: IndexPath(row: 0, section: section)) {
      return propertySection.tableView(tableView, numberOfRowsInSection: section)
    }
    return super.tableView(tableView, numberOfRowsInSection: section)
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if getPropertySection(at: indexPath) != nil {
      return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: indexPath.section))
    }
    return super.tableView(tableView, heightForRowAt: indexPath)
  }

  /**
   * Without this override, the default implementation will try to get a table cell that is out of bounds
   * (since they are inserted/removed at a slightly different time than the actual data source is updated).
   */
  override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
    return 0
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if let propertySection = getPropertySection(at: indexPath) {
      return propertySection.tableView(tableView, canEditRowAt:indexPath)
    }
    return false
  }

  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let propertySection = getPropertySection(at: indexPath) {
      return propertySection.tableView(tableView, cellForRowAt:indexPath)
    }
    return super.tableView(tableView, cellForRowAt: indexPath)
  }

  func getPropertySection(at indexPath: IndexPath) -> PropertiesTableSection? {
    if (eventPropertiesSection.hasSectionId(indexPath.section)) {
      return eventPropertiesSection
    } else if (targetPropertiesSection.hasSectionId(indexPath.section)) {
      return targetPropertiesSection
    }
    return nil
  }
}
