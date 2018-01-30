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
    }
    
    @IBAction func testSerial(_ sender: Any) {
        testFor(OperationQueue.serial)
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
                print("task: \(index)/\(queue.operationCount)  ->  \(task.currentRequest?.url?.absoluteString)")
                if queue.operationCount == 0 {
                    print("========================");
                }
            })
            operation = SessionTaskOperation(task: task)
        } else {
            operation = AsyncBlockOperation(asyncTask: { finished in
                var finishe = finished
                let t = UInt64(arc4random_uniform(10))
//                DispatchQueue.main.asyncAfter(deadline: .now() + t, execute: {
//                    print("task: \(index)/\(queue.operationCount)  ->  \(t)")
//                    finishe = true
//                })
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

