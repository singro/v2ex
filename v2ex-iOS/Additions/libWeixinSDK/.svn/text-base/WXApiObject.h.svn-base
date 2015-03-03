//
//  MMApiObject.h
//  ApiClient
//
//  Created by Tencent on 12-2-28.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! @brief 错误码
 *
 */
enum  WXErrCode {
    
    WXSuccess           = 0,    /**< 成功    */
    WXErrCodeCommon     = -1,   /**< 普通错误类型    */
    WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
    WXErrCodeSentFail   = -3,   /**< 发送失败    */
    WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
    WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
};

/*! @brief 请求发送场景
 *
 */
enum WXScene {
    
    WXSceneSession  = 0,        /**< 聊天界面    */
    WXSceneTimeline = 1,        /**< 朋友圈      */
    WXSceneFavorite = 2,        /**< 我的收藏    */
};

/*! @brief 该类为微信终端SDK所有请求类的基类
 *
 */
@interface BaseReq : NSObject

/** 请求类型 */
@property (nonatomic, assign) int type;
@end

/*! @brief 该类为微信终端SDK所有响应类的基类
 *
 */
@interface BaseResp : NSObject
/** 错误码 */
@property (nonatomic, assign) int errCode;
/** 错误提示字符串 */
@property (nonatomic, retain) NSString *errStr;
/** 响应类型 */
@property (nonatomic, assign) int type;

@end

@class WXMediaMessage;

/*! @brief 第三方程序发送消息至微信终端程序的接口
 *
 * 第三方程序向微信发送信息需要调用此接口，并传入具体请求类型作为参数。请求的信息内容包括文本消息和多媒体消息，
 * 分别对应于text和message成员。调用该方法后，微信处理完信息会向第三方程序发送一个处理结果。
 * @see SendMessageToWXResp
 */
@interface SendMessageToWXReq : BaseReq
/** 发送消息的文本内容
 * @attention 文本长度必须大于0且小于10K
 */
@property (nonatomic, retain) NSString* text;
/** 发送消息的多媒体内容
 * @see WXMediaMessage
 */
@property (nonatomic, retain) WXMediaMessage* message;
/** 发送消息的类型，包括文本消息和多媒体消息两种
 * @attention 两者只能选择其一，不能同时发送文本和多媒体消息
 */
@property (nonatomic, assign) BOOL bText;

/** 发送的目标场景，可以选择发送到聊天界面(WXSceneSession)、朋友圈(WXSceneTimeline)或我的收藏(WXSceneFavorite)。 
 * @note 默认发送到聊天界面。
 * @see WXScene
 */
@property (nonatomic, assign) int scene;

@end

/*! @brief 第三方程序发送SendMessageToWXReq至微信，微信处理完成后返回的处理结果类型。
 *
 * 第三方程序向微信终端发送SendMessageToWXReq后，微信发送回来的处理结果，该结果用SendMessageToWXResp表示。
 */
@interface SendMessageToWXResp : BaseResp
@end

/*! @brief 微信终端向第三方程序请求提供内容请求类型。
 *
 * 微信终端向第三方程序请求提供内容，微信终端会向第三方程序发送GetMessageFromWXReq请求类型，
 * 需要第三方程序调用sendResp返回一个GetMessageFromWXResp消息结构体。
 */
@interface GetMessageFromWXReq : BaseReq
@end

/*! @brief 微信终端向第三方程序请求提供内容，第三方程序向微信终端返回处理结果类型。
 *
 * 微信终端向第三方程序请求提供内容，第三方程序调用sendResp向微信终端返回一个GetMessageFromWXResp消息结构体。
 */
@interface GetMessageFromWXResp : BaseResp
/** 向微信终端提供的文本内容
 * @attention 文本长度必须大于0且小于10K
 */
@property (nonatomic, retain) NSString* text;
/** 向微信终端提供的多媒体内容。
 * @see WXMediaMessage
 */
@property (nonatomic, retain) WXMediaMessage* message;
/** 向微信终端提供内容的消息类型，包括文本消息和多媒体消息两种
 * @attention 两者只能选择其一，不能同时发送文本和多媒体消息 
 */
@property (nonatomic, assign) BOOL bText;
@end

/*! @brief 微信通知第三方程序，要求第三方程序显示的消息结构体。
 *
 * 微信需要通知第三方程序显示或处理某些内容时，会向第三方程序发送ShowMessageFromWXReq消息结构体。
 * 第三方程序处理完内容后调用sendResp向微信终端发送ShowMessageFromWXResp。
 */
@interface ShowMessageFromWXReq : BaseReq
/** 微信终端向第三方程序发送的要求第三方程序处理的多媒体内容
 * @see WXMediaMessage
 */
@property (nonatomic, retain) WXMediaMessage* message;
@end

/*! @brief 微信通知第三方程序，要求第三方程序显示或处理某些消息，第三方程序处理完后向微信终端发送的处理结果。
 *
 * 微信需要通知第三方程序显示或处理某些内容时，会向第三方程序发送ShowMessageFromWXReq消息结构体。
 * 第三方程序处理完内容后调用sendResp向微信终端发送ShowMessageFromWXResp。
 */
@interface ShowMessageFromWXResp : BaseResp
@end

/*! @brief 微信终端打开第三方程序请求类型
 *
 *  微信向第三方发送的结构体，第三方不需要返回
 */
@interface LaunchFromWXReq : BaseReq
@end


#pragma mark - WXMediaMessage

/*! @brief 多媒体消息结构体
 *
 * 用于微信终端和第三方程序之间传递消息的多媒体消息内容
 */
@interface WXMediaMessage : NSObject

+(WXMediaMessage *) message;

/** 标题
 * @attention 长度不能超过512字节
 */
@property (nonatomic, retain) NSString *title;
/** 描述内容
 * @attention 长度不能超过1K
 */
@property (nonatomic, retain) NSString *description;
/** 缩略图数据
 * @attention 大小不能超过32K
 */
@property (nonatomic, retain) NSData   *thumbData;
/** 多媒体消息标签，第三方程序可选填此字段，用于数据运营统计等
 * @attention 长度不能超过64字节
 */
@property (nonatomic, retain) NSString *mediaTagName;
/** 多媒体数据对象，可以为WXImageObject，WXMusicObject，WXVideoObject，WXWebpageObject等。 */
@property (nonatomic, retain) id        mediaObject;

/*! @brief 设置消息缩略图的方法
 *
 * @param image 缩略图
 * @attention 大小不能超过32K
 */
- (void) setThumbImage:(UIImage *)image;

@end


#pragma mark -
/*! @brief 多媒体消息中包含的图片数据对象
 *
 * 微信终端和第三方程序之间传递消息中包含的图片数据对象。
 * @attention imageData和imageUrl成员不能同时为空
 * @see WXMediaMessage
 */
@interface WXImageObject : NSObject
/*! @brief 返回一个WXImageObject对象
 *
 * @note 返回的WXImageObject对象是自动释放的
 */
+(WXImageObject *) object;

/** 图片真实数据内容
 * @attention 大小不能超过10M
 */
@property (nonatomic, retain) NSData    *imageData;
/** 图片url
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString  *imageUrl;

@end

/*! @brief 多媒体消息中包含的音乐数据对象
 *
 * 微信终端和第三方程序之间传递消息中包含的音乐数据对象。
 * @attention musicUrl和musicLowBandUrl成员不能同时为空。
 * @see WXMediaMessage
 */
@interface WXMusicObject : NSObject
/*! @brief 返回一个WXMusicObject对象
 *
 * @note 返回的WXMusicObject对象是自动释放的
 */
+(WXMusicObject *) object;

/** 音乐网页的url地址
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString *musicUrl;
/** 音乐lowband网页的url地址
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString *musicLowBandUrl;
/** 音乐数据url地址
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString *musicDataUrl;

/**音乐lowband数据url地址
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString *musicLowBandDataUrl;

@end

/*! @brief 多媒体消息中包含的视频数据对象
 *
 * 微信终端和第三方程序之间传递消息中包含的视频数据对象。
 * @attention videoUrl和videoLowBandUrl不能同时为空。
 * @see WXMediaMessage
 */
@interface WXVideoObject : NSObject
/*! @brief 返回一个WXVideoObject对象
 *
 * @note 返回的WXVideoObject对象是自动释放的
 */
+(WXVideoObject *) object;

/** 视频网页的url地址
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString *videoUrl;
/** 视频lowband网页的url地址
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString *videoLowBandUrl;

@end

/*! @brief 多媒体消息中包含的网页数据对象
 *
 * 微信终端和第三方程序之间传递消息中包含的网页数据对象。
 * @see WXMediaMessage
 */
@interface WXWebpageObject : NSObject
/*! @brief 返回一个WXWebpageObject对象
 *
 * @note 返回的WXWebpageObject对象是自动释放的
 */
+(WXWebpageObject *) object;

/** 网页的url地址
 * @attention 不能为空且长度不能超过10K
 */
@property (nonatomic, retain) NSString *webpageUrl;

@end

/*! @brief 多媒体消息中包含的App扩展数据对象
 *
 * 第三方程序向微信终端发送包含WXAppExtendObject的多媒体消息，
 * 微信需要处理该消息时，会调用该第三方程序来处理多媒体消息内容。
 * @note url，extInfo和fileData不能同时为空
 * @see WXMediaMessage
 */
@interface WXAppExtendObject : NSObject
/*! @brief 返回一个WXAppExtendObject对象
 *
 * @note 返回的WXAppExtendObject对象是自动释放的
 */
+(WXAppExtendObject *) object;

/** 若第三方程序不存在，微信终端会打开该url所指的App下载地址
 * @attention 长度不能超过10K
 */
@property (nonatomic, retain) NSString *url;
/** 第三方程序自定义简单数据，微信终端会回传给第三方程序处理
 * @attention 长度不能超过2K
 */
@property (nonatomic, retain) NSString *extInfo;
/** App文件数据，该数据发送给微信好友，微信好友需要点击后下载数据，微信终端会回传给第三方程序处理
 * @attention 大小不能超过10M
 */
@property (nonatomic, retain) NSData   *fileData;

@end

/*! @brief 多媒体消息中包含的表情数据对象
 *
 * 微信终端和第三方程序之间传递消息中包含的表情数据对象。
 * @see WXMediaMessage
 */
@interface WXEmoticonObject : NSObject

/*! @brief 返回一个WXEmoticonObject对象
 *
 * @note 返回的WXEmoticonObject对象是自动释放的
 */
+(WXEmoticonObject *) object;

/** 表情真实数据内容
 * @attention 大小不能超过10M
 */
@property (nonatomic, retain) NSData    *emoticonData;

@end

/*! @brief 多媒体消息中包含的文件数据对象
 *
 * @see WXMediaMessage
 */
@interface WXFileObject : NSObject

/*! @brief 返回一个WXFileObject对象
 *
 * @note 返回的WXFileObject对象是自动释放的
 */
+(WXFileObject *) object;

/** 文件后缀名
 * @attention 长度不超过64字节
 */
@property (nonatomic, retain) NSString  *fileExtension;

/** 文件真实数据内容
 * @attention 大小不能超过10M
 */
@property (nonatomic, retain) NSData    *fileData;

@end
