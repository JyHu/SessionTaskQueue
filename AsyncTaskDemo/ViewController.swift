//
//  ViewController.swift
//  AsyncTaskDemo
//
//  Created by 胡金友 on 2018/1/27.
//

import UIKit
import AsyncTaskQueue

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func testConcurrent(_ sender: Any) {
        testFor(OperationQueue.concurrent)
        OperationQueue.concurrent.addObserverWith(.Changed) { queue in
            print("lasted -> \(queue.operationCount)");
        }
    }
    
    @IBAction func testSerial(_ sender: Any) {
        testFor(OperationQueue.serial)
        OperationQueue.serial.addObserverWith(.Changed) { queue in
            print("lasted -> \(queue.operationCount)");
        }
    }
    
    @IBAction func testTempSerial(_ sender: Any) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        testFor(queue)
    }
    
    @IBAction func testDependency(_ sender: Any) {
        
    }
    
    func testFor(_ queue:OperationQueue) {
        for i in 0..<50 {
            let _ = self.operationWith(queue: queue, index: i, dependencies: nil)
        }
    }
    
    func operationWith(queue:OperationQueue, index:Int, dependencies:[Operation]?) -> Operation {
        var operation:Operation!
        if arc4random_uniform(2) == 1 {
            let u1 = "http://f.hiphotos.baidu.com/image/pic/item/503d269759ee3d6db032f61b48166d224e4ade6e.jpg"
            let u2 = "https://github.com/casatwy/RTNetworking/archive/master.zip"
            let request = URLRequest(url: URL(string: arc4random_uniform(2) == 1 ? u1 : u2)!)
            
            var task:URLSessionTask!
            task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                queue.completeSessionTask(task)
                print("task: \(index)/\(queue.operationCount)  ->  \(String(describing: task.currentRequest?.url?.absoluteString))")
                if queue.operationCount == 0 {
                    print("========================");
                }
            })
            operation = SessionTaskOperation(task: task)
        } else {
            operation = AsyncBlockOperation(asyncTask: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    queue.completeOperation(operation as? OperationTaskProtocol)
                    print("block: \(index)/\(queue.operationCount)")
                })
            })
        }
        
        operation.addDependencies(dependencies)
        queue.addOperation(operation)
        
        return operation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

