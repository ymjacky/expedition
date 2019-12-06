//
//  ViewController.swift
//  expedition
//
//  Created by 山崎祥司 on 2019/09/13.
//  Copyright © 2019 山崎祥司. All rights reserved.
//

// swift 文法諸々 https://employment.en-japan.com/engineerhub/entry/2017/05/25/110000
// よく忘れるOptional https://qiita.com/koher/items/c6f446bad54442a28bf4
// NFC 分類 https://qiita.com/kurotsu/items/0748961a59a33a045d33
// [Core Location Framework] CLLocationManagerDelegateの実装が必要



import UIKit
import MapKit
import CoreLocation // Core Location フレームワーク　（デバイスの地理的位置と向きを取得する）
import CoreNFC // Core NFC フレームワーク


class ViewController: UIViewController, CLLocationManagerDelegate, NFCNDEFReaderSessionDelegate {

    private let masterLocations: Dictionary<String, CLLocation> = [
        // 東京
        "戸越銀座温泉": CLLocation(latitude: 35.614973, longitude: 139.718936),
        "東京染井温泉SAKURA": CLLocation(latitude: 35.738057, longitude: 139.739930),
        "鷗外温泉": CLLocation(latitude: 35.716455, longitude: 139.770049),
        "東京前野原温泉さやの湯処": CLLocation(latitude: 35.771077, longitude: 139.693196),
        // 茨城
        "天然温泉きぬの湯": CLLocation(latitude: 35.983200, longitude: 139.964557),
        // 埼玉
        "竜泉寺の湯 草加谷塚店": CLLocation(latitude: 35.814517, longitude: 139.788396),
        "天然温泉 野天湯元 湯快爽快 湯けむり横丁 埼玉三郷店": CLLocation(latitude: 35.850758, longitude: 139.864516),
        "杉戸天然温泉 雅楽の湯": CLLocation(latitude: 36.041397, longitude: 139.741367),
        "早稲田天然温泉 めぐみの湯": CLLocation(latitude: 35.851993, longitude: 139.878843),
        "よしかわ天然温泉ゆあみ": CLLocation(latitude: 35.882955, longitude: 139.873613),
        // 千葉
        "法典の湯": CLLocation(latitude: 35.735486, longitude: 139.965116),
        "天然温泉 湯～ねる": CLLocation(latitude: 35.665686, longitude: 140.014745),
        "極楽湯 柏店": CLLocation(latitude: 35.886293, longitude: 139.976954),
        "天然温泉 白井の湯": CLLocation(latitude: 35.827422, longitude: 140.139672),
        "真名井の湯 千葉ニュータウン店": CLLocation(latitude: 35.801600, longitude: 140.140181),
        "ORIENTAL RESORT ReSpa INZAI リスパ印西": CLLocation(latitude: 35.806941, longitude: 140.174047),
        "龍泉の湯": CLLocation(latitude: 35.806777, longitude: 140.307557),
        "大和の湯": CLLocation(latitude: 35.817267, longitude: 140.272144),
        "のだ温泉 ほのか": CLLocation(latitude: 35.940058, longitude: 139.882119),
        "七光台温泉": CLLocation(latitude: 35.982439, longitude: 139.850674),
        "みのりの湯柏健康センター": CLLocation(latitude: 35.883449, longitude: 139.962957)
    ]
    
    private let numArray:[CLLocation] = [
        CLLocation(latitude: 35.61529284902742, longitude: 139.73070759877672)]

    // [Core Location Framework]
    var locationManager: CLLocationManager!
    
    // [Core NFC Framework]
    var nfcSession: NFCNDEFReaderSession!
    
    // 現在地：座標情報
    private var currentLocation: CLLocation? //CLLocation Optional型
    
    
    // Reference the found NFC messages
    private var nfcMessages: [[NFCNDEFMessage]] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func nfcButton(_ sender: Any) {
        
//        if Thread.isMainThread {
//            print("MainThreadです")
//        } else {
//            print("MainThreadではない")
//        }
        
        // 現在地をログに表示
        //print("latitude: \(latitude)\nlongitude: \(longitude)")
        print(currentLocation!)
        
        
        // NFCの利用制限確認
        if NFCNDEFReaderSession.readingAvailable {
            nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            nfcSession?.alertMessage = "NFCタグをiPhoneに近づけてください"
            nfcSession?.begin()
        } else {
            print("NFCが使えません")
        }
        
    }
    
    // インスタンス化された直後（初回に一度のみ）に動作するメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [Core Location Framework] ローケーションマネージャ初期化
        setupLocationManager()
    }
    
    // [Core Location Framework] ローケーションマネージャ初期化
    func setupLocationManager() {
        
        locationManager = CLLocationManager()
        // ローケーションマネージャの初期化成功時にのみunwarpして、位置情報を取得する許可をリクエスト
        guard let locationManager = locationManager else { return }
        
        // OSアプリでは、ユーザーの位置や連絡先などプライバシーに関わる情報を取得する前に
        // ユーザーから許可を得る必要がある
        // 認証リクエストAPIには使用用途に応じて次の２種類がある
        //  起動時のみ: requestWhenInUseAuthorization
        //  常時: requestAlwaysAuthorization
        //
        //  requestWhenInUseAuthorization
        //      アプリまたはその機能が画面上に表示されている時だけ、位置情報の利用を許可する
        //  requestAlwaysAuthorization
        //      バックグラウンドで実行中の場合にも位置情報の利用を許可する
        //  利用目的をInfo.plistに記載しなければならない。
        // 位置情報を取得する許可をリクエスト
        locationManager.requestWhenInUseAuthorization()
        
        // status = true 「アプリ使用中の位置情報取得」の許可が得られた
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.restricted || status == CLAuthorizationStatus.denied {
            NSLog("Location is not available")
            return
        }
        if status == .authorizedWhenInUse {
            // ロケーションマネージャの設定
            locationManager.distanceFilter = 10 // 位置情報を更新するペース （メートル）
            locationManager.startUpdatingLocation() // 位置情報の取得を開始
            locationManager.delegate = self // ViewControllerクラスが管理マネージャのデリゲート先になるようにする
        }
        
    }
    
    // [Core Location Framework] CLLocationManagerDelegateの実装
    // (didUpdateLocations) 位置情報を取得・更新するたびに呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude ?? 0 // 経度
        let longitude = location?.coordinate.longitude ?? 0 // 緯度
        
        // 表示するマップの中心を、取得した位置情報のポイントに指定
        currentLocation = locations.first;
        let locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mapView.setCenter(locationCoordinate, animated: false)

        // map の縮尺
        var region = mapView.region
        region.center = locationCoordinate
        // region.span.latitudeDelta = 0.002
        // region.span.longitudeDelta = 0.002
        region.span.latitudeDelta = 0.020
        region.span.longitudeDelta = 0.020
        mapView.setRegion(region, animated: true)
        
        // アノテーションの設定
        for (title, location) in masterLocations {

            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = title
            self.mapView.addAnnotation(annotation)
        }

    }
    
    // [Core NFC Framework] delegate
    //読み取りエラーが起こった時呼ばれる。ユーザーがキャンセルボタンを押すか、タイムアウトしたときに呼ばれる。
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        

        // コメントアウトするとエラーが出る
//        let alertController = UIAlertController(title:"Read NFC faild", message: "NFC読み取りに失敗しました", preferredStyle: .alert)
//        let defaultAction = UIAlertAction(title:"OK", style: .default, handler: nil)
//        alertController.addAction(defaultAction)
//        present(alertController, animated: false, completion: nil)
    }
    
    // [Core NFC Framework] delegate
    /// 読み取りに成功したら呼ばれる。
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
//        if Thread.isMainThread {
//            print("readerSession MainThreadです")
//        } else {
//            print("readerSession MainThreadではない")
//        }
        
        //DispatchQueue.main.async {
        for message in messages{
            for record in message.records {
                
                print("Type name format: \(record.typeNameFormat)")
                
                if let type_ = String.init(data: record.type, encoding: .utf8) {
                    print("type: \(type_)")
                    
                }
                if let identifier = String.init(data: record.identifier, encoding: .utf8) {
                    print("identifier: \(identifier)")
                }

                // NDEF Text Format (https://github.com/somq/nfccard-tool/blob/master/docs/NFC%20Text%20Record%20Type%20Definition%20Technical%20Specification.pdf)

                let payload = MyNDEFStringPayload(payload: record.payload)
                print("language: \(payload.language!)")
                print("text: \(payload.text!)")
                //print(String.init(data: record.payload, encoding: .utf8))
                
                // NFC and LOCATION
                let locationKey = payload.text!
                if let location = masterLocations[locationKey]{
                    
                    let distance = location.distance(from: currentLocation!)
                    if (distance < 100) { // 100 メートル以内にいる
                        print("ようこそ, \(locationKey)へ。（\(location))")
                    }
                }
                
                
                print("読み取ったよ")
                
            }
            
            // Add the new messages to our found messages
            self.nfcMessages.append(messages)
        }
        
        print("読み取り終了")
        //}

    }
    
}

class MyNDEFStringPayload {
    public let language:String?
    public let text:String?
    
    init(payload:Data) {
        
        if let first = payload.first {
            let len:UInt8 = first & 0b00111111
            
            let encodingMark:UInt8 = first & 0b10000000
            
            var enco = String.Encoding.utf8
            if (encodingMark == 0b10000000) {
                // encoding utf-8
                enco = String.Encoding.utf16
            }
            
            // 最初にlanguageが可変長で存在する
            language = String.init(
                data: payload[payload.index(payload.startIndex, offsetBy: 1)...payload.index(payload.startIndex, offsetBy: Int.init(len))],
                encoding: .ascii)
            // 残りが実際のText
            text = String.init(
                data: payload[payload.index(payload.startIndex, offsetBy: Int.init(len) + 1)...],
                encoding: enco)
        }
        else {
            language = nil
            text = nil
        }
    }
}

