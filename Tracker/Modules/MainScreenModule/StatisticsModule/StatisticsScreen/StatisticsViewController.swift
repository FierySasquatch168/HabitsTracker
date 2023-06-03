//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    let viewModel: StatisticsViewModel
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableViewCellSpacing: CGFloat = 18
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.Icons.statisticsEmptyState)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateTextLabel: UILabel = {
        let label = UILabel()
        let text = NSLocalizedString(Constants.LocalizableStringsKeys.statisticsEmptyStateText, comment: "String showed when there is no statistics to show")
        let attrs = [
            NSAttributedString.Key.font : UIFont(name: CustomFonts.YPMedium.rawValue, size: 12),
            NSAttributedString.Key.foregroundColor : UIColor.YPBlack
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attrs as [NSAttributedString.Key : Any])
        
        return label
    }()
    
    private lazy var emptyStateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.addArrangedSubview(emptyStateImageView)
        stackView.addArrangedSubview(emptyStateTextLabel)
        
        return stackView
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        return table
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadStatistics()
    }
    
    private func bind() {
        viewModel.$statistics.bind { statisticsModelArray in
            self.emptyStateStackView.isHidden = !statisticsModelArray.isEmpty
            self.tableView.isHidden = statisticsModelArray.isEmpty
            self.tableView.reloadData()
        }
    }
}

// MARK: - Ext collectionView dataSource
extension StatisticsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.statistics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else { return UITableViewCell() }
        let count = viewModel.statistics[indexPath.section].number
        let title = viewModel.statistics[indexPath.section].title
        cell.setupCellWithValues(count: count, title: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = tableView.backgroundColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Ext TableView delegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 4.0 - tableViewCellSpacing
    }
}

// MARK: - Constraints
private extension StatisticsViewController {
    func setupConstraints() {
        setupTableView()
        setupEmptyStateStackView()
    }
    
    func setupEmptyStateStackView() {
        view.addSubview(emptyStateStackView)
        emptyStateStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -127)
        ])
    }
}
