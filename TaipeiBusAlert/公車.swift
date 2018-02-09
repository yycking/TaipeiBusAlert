//
//  公車.swift
//  TaipeiBusAlert
//
//  Created by Wayne Yeh on 2018/2/9.
//  Copyright © 2018年 Wayne Yeh. All rights reserved.
//

import Foundation

private class 位置: Decodable {
    let name: String
    let CenterName: String
}

private class 必要訊息: Decodable {
    let Location: 位置
    let UpdateTime: String
    let CoordinateSystem: String
}

public class 路線訊息: Decodable {
    let Id: Int //路線代碼
    let providerId: Int //業者代碼
    let providerName: String //業者中文名稱
    let nameZh: String //中文名稱
    let nameEn: String //英文名稱
    let pathAttributeId: Int //所屬附屬路線 ID
    let pathAttributeName: String // 所屬附屬路線中文名稱
    let pathAttributeEname: String // 所屬附屬路線英文名稱
    let buildPeriod: String // 建置時間，分為 1：1 期、2：2 期、3：3 期、9：非動態資料、10：北縣
    let departureZh: String // '去程第 1 站'  起站中文名稱
    let departureEn: String // '去程第 1 站'  起站英文名稱
    let destinationZh: String // '回程第 1 站'  訖站中文名稱
    let destinationEn: String // '回程第 1 站'  訖站英文名稱
    let realSequence: String // 核定總班次
    let distance: String // 總往返里程(公里/全程)
    let goFirstBusTime: String // 站牌顯示時使用，去程第一班發車時間(hhmm)
    let backFirstBusTime: String // 站牌顯示時使用，回程第一班發車時間(hhmm)
    let goLastBusTime: String // 站牌顯示時使用，去程最後一班發車時間(hhmm)
    let backLastBusTime: String // 站牌顯示時使用，回程最後一班發車時間(hhmm)
    let peakHeadway: String // 站牌顯示時使用，尖峰時段發車間隔(hhmm OR mm)
    let offPeakHeadway: String // 站牌顯示時使用，離峰時段發車間隔(hhmm OR mm)
    let busTimeDesc: String // 平日頭末班描述
    let holidayGoFirstBusTime: String // 假日站牌顯示時使用，去程第一班發車時間(HHmm)
    let holidayBackFirstBusTime: String // 假日站牌顯示時使用，回程第一班發車時間(HHmm)
    let holidayGoLastBusTime: String // 假日站牌顯示時使用，去程最後一班發車時間(HHmm)
    let holidayBackLastBusTime: String // 假日站牌顯示時使用，回程最後一班發車時間(HHmm)
    let holidayBusTimeDesc: String // 假日頭末班描述
    let headwayDesc: String // 平日發車間距描述
    let holidayPeakHeadway: String // 假日站牌顯示時使用，尖峰時段發車間隔(mmmm OR mm)
    let holidayOffPeakHeadway: String // 假日站牌顯示時使用，離峰時段發車間隔(mmmm OR mm)
    let holidayHeadwayDesc: String // 假日發車間距描述
    let segmentBufferZh: String // 分段緩衝區(中文)
    let segmentBufferEn: String // 分段緩衝區(英文)
    let ticketPriceDescriptionZh: String // 票價描述(中文)
    let ticketPriceDescriptionEn: String // 票價描述(英文)
    let RouteroadMapUrl: String? // 路線圖 URL
}

private class 路線: Decodable {
    let EssentialInfo: 必要訊息
    let BusInfo: [路線訊息]
}

public class 站牌訊息: Decodable {
    let Id: Int // 站牌代碼
    let routeId: Int // 所屬路線代碼 (主路線 ID)
    let nameZh: String // 中文名稱
    let nameEn: String? // 英文名稱
    let seqNo: Int // 於路線上的順序
    let pgp: String? // 上下車站別 （-1：可下車、0：可上下車、1：可上車）
    let goBack: String // 去返程 （0：去程 / 1：返程 / 2：未知）
    let longitude: String // 經度
    let latitude: String // 緯度
    let address: String? // 地址
    let stopLocationId: Int // 站位 ID
    let showLon: String // 顯示用經度
    let showLat: String // 顯示用緯度
    let vector: String? // 向量角：0~359，預設為空白
}

private class 站牌: Decodable {
    let EssentialInfo: 必要訊息
    let BusInfo: [站牌訊息]
}

public class 預估到站時間訊息: Decodable {
    let RouteID: Int // 路線代碼 (主路線 ID)
    let StopID: Int // 站牌代碼
    let EstimateTime: String //預估到站剩餘時間（單位：秒） -1：尚未發車 -2：交管不停靠 -3：末班車已過 -4：今日未營運
    let GoBack: String // 去返程 （0：去程 1：返程 2：尚未發車 3：末班已駛離）
}

private class 預估到站時間: Decodable {
    let EssentialInfo: 必要訊息
    let BusInfo: [預估到站時間訊息]
}

public class 公車 {
    private let 🌐 = "https://tcgbusfs.blob.core.windows.net"
    private let 🏴: String
    private var 🚌s = [路線訊息]()
    private var 🚏s = [站牌訊息]()
    private init(string: String) {
        🏴 = string
    }
    
    public static let 臺北市 = 公車(string: "blobbus")
    public static let 新北市 = 公車(string: "ntpcbus")
    
    private func call<T>(url: String, type: T.Type, complete:@escaping (_ object:T?)->Void) where T:Decodable {
        
        // 讀舊檔
        if let jsonData = UserDefaults.standard.data(forKey: "\(🏴)\(url)") {
            do {
                let object = try JSONDecoder().decode(type, from: jsonData)
                complete(object)
                return
            } catch {
                print("Unexpected error: \(error).")
            }
        }
        
        // 抓新檔
        let link = URL(string: "\(🌐)/\(🏴)/Get\(url).gz")
        URLSession.shared.dataTask(with: link!) { (data, response, error) in
            guard
                let gzdata = data,
                let jsonData = gzdata.gunzipped(),
                let json = String(data: jsonData, encoding: String.Encoding.utf8)
                else {
                    complete(nil)
                    return
            }
            UserDefaults.standard.set(json, forKey: url)
            
            do {
                let object = try JSONDecoder().decode(type, from: jsonData)
                complete(object)
            } catch {
                print("Unexpected error: \(error).")
                complete(nil)
            }
        }.resume()
    }
    
    public func 路線清單(complete:@escaping (_ buses:[路線訊息])->Void) {
        if 🚌s.isEmpty {
            call(url: "Route", type: 路線.self) {[weak self] (object) in
                guard let 💪self = self else {return}
                if let 🚦 = object {
                    for 🚌 in 🚦.BusInfo {
                        💪self.🚌s.append(🚌)
                    }
                }
                
                complete(💪self.🚌s)
            }
        } else {
            complete(🚌s)
        }
    }
    
    private func 站牌清單(complete:@escaping (_ buses:[站牌訊息])->Void) {
        if 🚏s.isEmpty {
            call(url: "Stop", type: 站牌.self) {[weak self] (object) in
                guard let 💪self = self else {return}
                if let 🚦 = object {
                    for 🚏 in 🚦.BusInfo {
                        💪self.🚏s.append(🚏)
                    }
                }
                
                complete(💪self.🚏s)
            }
        } else {
            complete(🚏s)
        }
    }
    
    public func 站牌清單(route: 路線訊息, goBack: Bool, complete:@escaping (_ buses:[站牌訊息])->Void) {
        站牌清單 { (list) in
            let newList = list.filter{ (🚏) -> Bool in
                return 🚏.routeId == route.Id && (🚏.goBack == "1" ) == goBack
                }.sorted{ (🚏1, 🚏2) -> Bool in
                    return 🚏1.seqNo < 🚏2.seqNo
                }
            complete(newList)
        }
    }
    
    func 到站時間(route: 路線訊息, stop: 站牌訊息, goBack: Bool, complete:@escaping (_ buses:[String])->Void) {
        let key = "EstimateTime"
        UserDefaults.standard.removeObject(forKey: "\(🏴)\(key)")
        call(url: key, type: 預估到站時間.self) {(object) in
            var list = [String]()
            if let 🚦 = object?.BusInfo {
                list = 🚦.filter{ (🚏) -> Bool in
                    return 🚏.RouteID == route.Id && (🚏.GoBack == "1" ) == goBack && 🚏.StopID == stop.Id
                }.map{ (🚏) -> String in
                        🚏.EstimateTime
                }
            }
            
            complete(list)
        }
    }
}
