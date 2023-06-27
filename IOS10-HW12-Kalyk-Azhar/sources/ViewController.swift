
import UIKit

class ViewController: UIViewController {
    
    private var isWorkTime = false
    private var isStarted = false
    private var timer: Timer?
    private var time = 25
    private let workTime = 25
    private let restTime = 15
    private var isPaused = false
    private let shapeLayer = CAShapeLayer()
   
    // MARK: - UI Elements
    
    private lazy var shapeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "\(Int(workTime))"
        label.font = UIFont.systemFont(ofSize: 80)
        label.textColor = UIColor(red: 0.92, green: 0.59, blue: 0.58, alpha: 1.00)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "pause.circle"), for: .selected)
        button.tintColor = UIColor(red: 0.80, green: 0.30, blue: 0.54, alpha: 1.00)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.transform = CGAffineTransform(scaleX: 2, y: 2)
        button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: 100, height: 100)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "image")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animationCircular()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayout()
    }
    
    private func setupHierarchy() {
        view.addSubview(imageView)
        view.addSubview(shapeView)
        view.addSubview(label)
        view.addSubview(button)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            shapeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shapeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            shapeView.heightAnchor.constraint(equalToConstant: 300),
            shapeView.widthAnchor.constraint(equalToConstant: 300),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7),
        ])
        updateUI()
    }
    
    @objc func buttonTapped() {
        isStarted.toggle()
        if isStarted {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                resumeLayer(layer: shapeLayer)
                progressAnimation(layer: shapeLayer, duration: TimeInterval(time))}
        } else {
            timer?.invalidate()
            timer = nil
            pauseLayer(layer: shapeLayer)
        }
        updateUI()
    }
    
    func startTimer() {
        guard timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateTimer() {
        label.text = "\(Int(time))"
        guard time > 0 else {
            timer?.invalidate()
            timer = nil
            time = isWorkTime ? workTime : restTime
            isWorkTime.toggle()
            isPaused = false
            updateUI()
            return
        }
        time -= 1
        updateUI()
    }
    
    func updateUI() {
        label.text = "\(Int(time))"
        button.isSelected = isStarted
    }
    
    // MARK: - Animation
    
    func animationCircular() {
        let center = CGPoint(x: shapeView.frame.width / 2, y: shapeView.frame.height / 2)
        let endAngle = (-CGFloat.pi / 2)
        let startAngle = 2 * CGFloat.pi + endAngle
        let circularPath = UIBezierPath(arcCenter: center, radius: 122, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = 21
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeColor = UIColor(red: 0.83, green: 0.77, blue: 0.98, alpha: 1.00).cgColor
        shapeView.layer.addSublayer(shapeLayer)
    }
    
    func progressAnimation(layer: CAShapeLayer, duration: TimeInterval) {
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        layer.strokeEnd = 1
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        layer.add(circularProgressAnimation, forKey: "progressAnimation")
    }
    
    func pauseLayer(layer: CAShapeLayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    func resumeLayer(layer: CAShapeLayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}
