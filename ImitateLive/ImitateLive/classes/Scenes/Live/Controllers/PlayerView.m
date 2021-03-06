//
//  PlayerView.m
//  ImitateLive
//
//  Created by ssx on 16/7/13.
//  Copyright © 2016年 SJH. All rights reserved.
//

#import "PlayerView.h"

@interface PlayerView ()

@end


@implementation PlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithUrl:(NSString *)url frame:(CGRect)frame {
    
    self = [super init];
    if (self) {
        self.frame = frame;
        _playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = frame;
//        _isPlaying = YES;
        [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            [_player play];
            _isPlaying = YES;
        }else if (_player.status == AVPlayerStatusFailed){
            _isPlaying = NO;
        }
    }
}



- (void)dealloc {
    [_player removeObserver:self forKeyPath:@"status" context:nil];
    
}


@end
