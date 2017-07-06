//
//  LyricsTTPod.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

extension Lyrics.MetaData.Source {
    static let TTPod = Lyrics.MetaData.Source("TTPod")
}

public final class LyricsTTPod: SingleResultLyricsProvider {
    
    let session = URLSession(configuration: .providerConfig)
    var task: URLSessionDataTask?
    
    public func iFeelLucky(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionHandler: @escaping (Lyrics?) -> Void) {
        guard case let .info(title, artist) = criteria else {
            // cannot search by keyword
            return
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        let urlStr = "http://lp.music.ttpod.com/lrc/down?lrcid=&artist=\(encodedArtist)&title=\(encodedTitle)"
        let url = URL(string: urlStr)!
        let req = URLRequest(url: url)
        task = session.dataTask(with: req) { data, resp, error in
            guard let data = data,
                let lrcContent = JSON(data)["data"]["lrc"].string,
                let lrc = Lyrics(lrcContent) else {
                    completionHandler(nil)
                    return
            }
            lrc.metadata.source = .TTPod
            lrc.metadata.searchBy = criteria
            lrc.metadata.searchIndex = 0
            completionHandler(lrc)
        }
        task?.resume()
    }
}
