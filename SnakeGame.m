//
//  SnakeGame.m
//  Snake
//
//  Created by Noy H on 11/01/2017.
//  Copyright © 2017 Inscriptio. All rights reserved.
//


#import "SnakeGame.h"
#import <stdlib.h>

int width = 7;
float speed = 0.1f;

@interface SnakeBlocks : NSObject

typedef struct {
    int x;
    int y;
} BlockPlacement;

@property (nonatomic, assign) BlockPlacement position;
@property (nonatomic, retain) NSBezierPath *path;

- (void)newPosition:(NSArray *)range;

@end

@implementation SnakeBlocks

NSRect _window;

BlockPlacement BlockSet(int x, int y) {
    BlockPlacement p;
    p.x = x;
    p.y = y;
    return p;
}

NSRect NSRectFromPosition(BlockPlacement placement) { return NSMakeRect(_window.origin.x + placement.x * width, _window.origin.y + placement.y * width, width, width); }

- (id)initWithScene:(NSRect)window {
    self = [super init];
    if (self) {
        _window = window;
        self.path = [NSBezierPath bezierPath];
    }
    return self;
}

- (void)render {
    [self.path removeAllPoints];
    [self.path appendBezierPathWithRect:NSRectFromPosition(self.position)];
}

- (void)newPosition:(NSArray *)range {
    NSPoint point = NSPointFromString(range[arc4random() % range.count]);
    self.position = BlockSet((int) point.x, (int) point.y);
}

@end

@interface Snake : NSObject

typedef enum {
    SnakeUp,
    SnakeDown,
    SnakeLeft,
    SnakeRight,
}SnakeFacing;

typedef NSPoint SnakePointArea;
typedef NSMutableArray SnakeBody;

@property (nonatomic, assign) SnakeFacing facing;
@property (nonatomic, retain) SnakeBody *body;
@property (nonatomic, assign) SnakePointArea head;
@property (nonatomic, assign) SnakePointArea tail;
@property (nonatomic, assign) SnakePointArea shadow;

@property (nonatomic, retain) NSMutableArray *areaNoSnake;

@property (nonatomic, retain) NSBezierPath *path;

- (void)move;
- (void)up;
- (void)down;
- (void)left;
- (void)right;

@end

@implementation Snake

NSRect _window;

NSRect NSRectFromNode(SnakePointArea area) {
    return NSMakeRect(_window.origin.x + area.x * width, _window.origin.y + area.y * width, width, width);
}

- (id)initWithScene:(NSRect)scene {
    self = [super init];
    if (self) {
        _window = scene;
        self.body = [[NSMutableArray alloc] init];
        self.areaNoSnake = [[NSMutableArray alloc] init];
        self.path = [NSBezierPath bezierPath];
        [self reset];
    }
    return self;
}

- (SnakePointArea)head { return NSPointFromString(self.body[0]); }

- (SnakePointArea)tail { return NSPointFromString([self.body lastObject]); }

- (void)reset {
    self.facing = SnakeUp;
    [self.body removeAllObjects];
    NSPoint point = NSMakePoint((int)(_window.size.width / width) / 2, (int)(_window.size.height / width) / 2);
    [self.body addObject:NSStringFromPoint(point)];
    [self.body addObject:NSStringFromPoint(NSMakePoint(point.x + 1, point.y))];
    [self.areaNoSnake removeAllObjects];
    for (int i = 0; i < (int)_window.size.width / width; i++) {
        for (int j = 0; j < (int)_window.size.height / width; j++) {
            [self.areaNoSnake addObject:NSStringFromPoint(NSMakePoint(i, j))];
        }
    }
    [self.areaNoSnake removeObject:NSStringFromPoint(self.head)];
    [self.areaNoSnake removeObject:NSStringFromPoint(self.tail)];
}

- (void)start {
    [self.path removeAllPoints];
    for (NSString *node in self.body) {
        SnakePointArea snakeNode = NSPointFromString(node);
        [self.path appendBezierPathWithRect:NSRectFromNode(snakeNode)];
    }
}

- (void)takeBlock {
    [self.body addObject:NSStringFromPoint(self.shadow)];
    [self.areaNoSnake removeObject:NSStringFromPoint(self.shadow)];
}

- (void)move {
    SnakePointArea nArea;
    switch (self.facing) {
        case SnakeUp: { nArea = NSMakePoint(self.head.x, self.head.y + 1); }
            break;
            
        case SnakeDown: { nArea = NSMakePoint(self.head.x, self.head.y - 1); }
            break;
            
        case SnakeLeft: { nArea = NSMakePoint(self.head.x - 1, self.head.y); }
            break;
            
        case SnakeRight: { nArea = NSMakePoint(self.head.x + 1, self.head.y); }
            break;
        default:
            break;
    }

    [self.body insertObject:NSStringFromPoint(nArea) atIndex:0];
    self.shadow = self.tail;
    [self.body removeLastObject];
    [self.areaNoSnake removeObject:NSStringFromPoint(nArea)];
    [self.areaNoSnake addObject:NSStringFromPoint(self.shadow)];
}

- (void)up { if (self.facing == SnakeLeft || self.facing == SnakeRight) { self.facing = SnakeUp; } }

- (void)down { if (self.facing == SnakeLeft || self.facing == SnakeRight) { self.facing = SnakeDown; } }

- (void)left { if (self.facing == SnakeUp || self.facing == SnakeDown) { self.facing = SnakeLeft; } }

- (void)right { if (self.facing == SnakeUp || self.facing == SnakeDown) { self.facing = SnakeRight; } }

@end

@implementation SnakeGame {
    Snake *snake;
    SnakeBlocks *_blocks;
    NSRect windowView;
    NSTimer *timer;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        windowView = NSMakeRect(0, 0, frame.size.width, frame.size.height);
        snake = [[Snake alloc] initWithScene:windowView];
        _blocks = [[SnakeBlocks alloc] initWithScene:windowView];
        [_blocks newPosition:snake.areaNoSnake];
        [self resume];
    }
    return self;
}

- (void)restart {
    [[NSApplication sharedApplication] stopModal];
    [self pause];
    [snake reset];
    [_blocks newPosition:snake.areaNoSnake];
    [self resume];
}

- (void)terminate {
    [[NSApplication sharedApplication] terminate:nil];
}

- (BOOL)collisionCheck {
    if (!NSContainsRect(windowView, NSRectFromNode(snake.head))) {
        [self gameOver];
        return YES;
    }
    for (int i = 1; i < snake.body.count; i++) {
        NSString *node = snake.body[i];
        SnakePointArea snakeNode = NSPointFromString(node);
        if (snakeNode.x == snake.head.x && snakeNode.y == snake.head.y) {
            [self gameOver];
            return YES;
        }
    }
    return NO;
}

- (void)blockTake {
    if ((int)snake.head.x == _blocks.position.x && (int)snake.head.y == _blocks.position.y) {
        [snake takeBlock];
        if (snake.areaNoSnake.count == 0) {
            [self win];
        } else {
            [_blocks newPosition:snake.areaNoSnake];
        }
    }
}

- (void)run {
    [snake move];
    [self blockTake];
    if (![self collisionCheck]) [self setNeedsDisplay:YES];
}

- (void)resume {
    [self run];
    timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(run) userInfo:nil repeats:YES];
}

- (void)pause { [timer invalidate]; }

- (void)gameOver {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Game Over!"];
    [alert addButtonWithTitle:@"Restart"];
    [alert addButtonWithTitle:@"Quit"];
    [alert.buttons[0] setTarget:self];
    [alert.buttons[0] setAction:@selector(restart)];
    [alert.buttons[1] setTarget:self];
    [alert.buttons[1] setAction:@selector(terminate)];
    [alert.buttons[1] setKeyEquivalent:@"\r"];
    [alert runModal];
}

- (void)win {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"You win!"];
    [alert runModal];
}

// utils

- (void)drawRect:(NSRect)dirtyRect {
    // Background colour
    [super drawRect:dirtyRect];
    [[NSColor blueColor] set];
    NSRectFill(windowView);

    // Snake Colour
    [[NSColor greenColor] set];
    [snake start];
    [snake.path fill];

    // Block Colour
    [[NSColor redColor] set];
    [_blocks render];
    [_blocks.path fill];
}

- (BOOL)acceptsFirstResponder { return YES; }

// Reminds me of Java xD
- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
        NSString *pointer = [theEvent charactersIgnoringModifiers];
        unichar keyChar = 0;
        if ([pointer length] == 0) return;
        if ([pointer length] == 1 ) {
            [self pause];
            keyChar = [pointer characterAtIndex:0];
            switch (keyChar) {
                case NSLeftArrowFunctionKey:
                    [snake left];
                    break;
                case NSRightArrowFunctionKey:
                    [snake right];
                    break;
                case NSUpArrowFunctionKey:
                    [snake up];
                    break;
                case NSDownArrowFunctionKey:
                    [snake down];
                    break;
                default:
                    break;
            }
            [self resume];
            return;
        }
    }
    [super keyDown:theEvent];
}
@end
