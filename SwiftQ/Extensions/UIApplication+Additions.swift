//
//  UIApplication+Additions.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import UIKit

extension UIApplication {
	var presentingViewController: UIViewController? {
		(connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
	}
}
