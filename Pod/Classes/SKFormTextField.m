//
//  Created by Shyngys Kassymov on 02.10.15.
//  Copyright © 2015 Shyngys Kassymov. All rights reserved.
//

#import "SKFormTextField.h"

#pragma mark - SKFormTextField
#pragma mark -

#define DEFAULT_TEXT_FIELD_HEIGHT 35
#define NORMAL_COLOR [UIColor colorWithRed:134/255.0 green:134/255.0 blue:134/255.0 alpha:1.0]
#define ACTIVE_COLOR [UIColor colorWithRed:0/255.0 green:150/255.0 blue:136/255.0 alpha:1.0]
#define VALID_COLOR NORMAL_COLOR
#define ERROR_COLOR [UIColor colorWithRed:219/255.0 green:68/255.0 blue:55/255.0 alpha:1.0]

static CGFloat const kFloatingLabelShowAnimationDuration = 0.3f;
static CGFloat const kFloatingLabelHideAnimationDuration = 0.3f;

@interface SKFormTextField ()

@end

@implementation SKFormTextField {
    BOOL hasSetuped;
    BOOL _isFloatingLabelFontDefault;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initVars];
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initVars];
        [self setup];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Update UI elements
    [self updateUI];
}

- (void)initVars {
    // Initialize default values
    self.textFieldState = SKFormTextFieldStateDefault;
    self.mode = SKFormTextFieldModeWrite;
    self.lineNormalColor = [[UIColor blackColor] colorWithAlphaComponent:0.12];
    self.lineActiveColor = ACTIVE_COLOR;
    self.lineValidColor = [[UIColor blackColor] colorWithAlphaComponent:0.12];
    self.lineErrorColor = ERROR_COLOR;
    self.descriptionNormalColor = NORMAL_COLOR;
    self.descriptionActiveColor = NORMAL_COLOR;
    self.descriptionValidColor = VALID_COLOR;
    self.descriptionErrorColor = ERROR_COLOR;
    self.placeholderText = @"";
    self.descriptionText = @"";
    self.errorMessageText = @"";
    self.textViewHeight = DEFAULT_TEXT_FIELD_HEIGHT;
}

- (void)setup {
    // Check if view has already been setuped
    if (!hasSetuped) {
        // Create and add views to main view
        if (!self.leftButton) {
            self.leftButton = [UIButton new];
            self.leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            if (self.leftButtonImage) {
                [self.leftButton setImage:self.leftButtonImage forState:UIControlStateNormal];
            }
            [self addSubview:self.leftButton];
        }
        if (!self.textField) {
            self.textField = [UITextField new];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
            
            self.textField.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
            self.textField.placeholder = self.placeholderText;
            [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [self addSubview:self.textField];
            
            _floatingLabel = [UILabel new];
            _floatingLabel.alpha = 0.0f;
            [self.textField addSubview:_floatingLabel];
            
            // some basic default fonts/colors
            _floatingLabelFont = [self defaultFloatingLabelFont];
            _floatingLabel.font = _floatingLabelFont;
            _floatingLabelTextColor = [UIColor colorWithRed:163.f/255.f green:137.f/255.f blue:83.f/255.f alpha:1.f];
            _floatingLabel.textColor = _floatingLabelTextColor;
            _animateEvenIfNotFirstResponder = NO;
            _floatingLabelShowAnimationDuration = kFloatingLabelShowAnimationDuration;
            _floatingLabelHideAnimationDuration = kFloatingLabelHideAnimationDuration;
            [self setFloatingLabelText:self.textField.placeholder];
            
            _adjustsClearButtonRect = YES;
            _isFloatingLabelFontDefault = YES;
        }
        if (!self.datePicker) {
            self.dateFormatter = [NSDateFormatter new];
            [self.dateFormatter setDateFormat:@"dd/MM/yyyy"];
        }
        if (!self.datePicker) {
            self.datePicker = [UIDatePicker new];
            self.datePicker.backgroundColor = [UIColor whiteColor];
            [self.datePicker addTarget:self action:@selector(datePickerDidChange:) forControlEvents:UIControlEventValueChanged];
            self.datePicker.datePickerMode = UIDatePickerModeDate;
        }
        if (!self.textView) {
            self.textView = [SKTextView new];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
            
            self.textView.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
            self.textView.placeholderText = self.placeholderText;
            [self addSubview:self.textView];
            self.textView.hidden = YES;
        }
        if (!self.rightButton) {
            self.rightButton = [UIButton new];
            self.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            if (self.rightButtonImage) {
                [self.rightButton setImage:self.rightButtonImage forState:UIControlStateNormal];
            }
            [self addSubview:self.rightButton];
        }
        if (!self.line) {
            self.line = [UIView new];
            self.line.backgroundColor = self.lineNormalColor;
            [self addSubview:self.line];
        }
        if (!self.leftDescriptionIcon) {
            self.leftDescriptionIcon = [UIImageView new];
            self.leftDescriptionIcon.contentMode = UIViewContentModeScaleAspectFit;
            if (self.leftIconImage) {
                self.leftDescriptionIcon.image = self.leftIconImage;
            }
            [self addSubview:self.leftDescriptionIcon];
        }
        if (!self.descriptionLabel) {
            self.descriptionLabel = [UILabel new];
            self.descriptionLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:12];
            self.descriptionLabel.textColor = self.descriptionNormalColor;
            self.descriptionLabel.numberOfLines = 0;
            self.descriptionLabel.preferredMaxLayoutWidth = self.descriptionLabel.frame.size.width;
            self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.descriptionLabel.text = self.descriptionText;
            [self addSubview:self.descriptionLabel];
        }
        if (!self.rightDescriptionIcon) {
            self.rightDescriptionIcon = [UIImageView new];
            self.rightDescriptionIcon.contentMode = UIViewContentModeScaleAspectFit;
            if (self.rightIconImage) {
                self.rightDescriptionIcon.image = self.rightIconImage;
            }
            [self addSubview:self.rightDescriptionIcon];
        }
        
        // Add constraints
        
        // left button
        self.leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftButtonHeightConstraint =
        [NSLayoutConstraint constraintWithItem:self.leftButton
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:24];
        self.leftButtonWidthConstraint =
        [NSLayoutConstraint constraintWithItem:self.leftButton
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:24];
        NSLayoutConstraint *leftButtonLeftConstaint =
        [NSLayoutConstraint constraintWithItem:self.leftButton
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *leftButtonVerticalCenterConstaint =
        [NSLayoutConstraint constraintWithItem:self.leftButton
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.textField
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0];
        [self addConstraints:@[self.leftButtonHeightConstraint, self.leftButtonWidthConstraint, leftButtonLeftConstaint, leftButtonVerticalCenterConstaint]];
        
        // text field
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textFieldHeightConstraint =
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:self.textViewHeight];
        NSLayoutConstraint *textFieldTopConstaint =
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *textFieldBottomConstaint =
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.line
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0];
        self.textFieldLeftConstraint =
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.leftButton
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:8];
        self.textFieldRightConstraint =
        [NSLayoutConstraint constraintWithItem:self.textField
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.rightButton
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:-8];
        [self addConstraints:@[self.textFieldHeightConstraint, textFieldTopConstaint, textFieldBottomConstaint, self.textFieldLeftConstraint, self.textFieldRightConstraint]];
        
        // textView
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *textViewTopConstraint =
        [NSLayoutConstraint constraintWithItem:self.textView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.textField
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *textViewLeftConstraint =
        [NSLayoutConstraint constraintWithItem:self.textView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.textField
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *textViewBottomConstraint =
        [NSLayoutConstraint constraintWithItem:self.textView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.textField
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *textViewRightConstraint =
        [NSLayoutConstraint constraintWithItem:self.textView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.textField
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0];
        [self addConstraints:@[textViewTopConstraint, textViewLeftConstraint, textViewBottomConstraint, textViewRightConstraint]];
        
        // right button
        self.rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightButtonHeightConstraint =
        [NSLayoutConstraint constraintWithItem:self.rightButton
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:24];
        self.rightButtonWidthConstraint =
        [NSLayoutConstraint constraintWithItem:self.rightButton
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:24];
        NSLayoutConstraint *rightButtonLeftConstaint =
        [NSLayoutConstraint constraintWithItem:self.rightButton
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *rightButtonVerticalCenterConstaint =
        [NSLayoutConstraint constraintWithItem:self.rightButton
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.textField
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0];
        [self addConstraints:@[self.rightButtonHeightConstraint, self.rightButtonWidthConstraint, rightButtonLeftConstaint, rightButtonVerticalCenterConstaint]];
        
        // line
        self.line.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *lineLeftConstraint =
        [NSLayoutConstraint constraintWithItem:self.line
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *lineRightConstraint =
        [NSLayoutConstraint constraintWithItem:self.line
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0];
        self.lineHeightConstraint =
        [NSLayoutConstraint constraintWithItem:self.line
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:1];
        [self addConstraints:@[lineLeftConstraint, lineRightConstraint, self.lineHeightConstraint]];
        
        // left icon
        self.leftDescriptionIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftImageHeightConstraint =
        [NSLayoutConstraint constraintWithItem:self.leftDescriptionIcon
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:18];
        self.leftImageWidthConstraint =
        [NSLayoutConstraint constraintWithItem:self.leftDescriptionIcon
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:18];
        NSLayoutConstraint *leftDescriptionIconLeftConstaint =
        [NSLayoutConstraint constraintWithItem:self.leftDescriptionIcon
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *leftDescriptionIconVerticalCenterConstaint =
        [NSLayoutConstraint constraintWithItem:self.leftDescriptionIcon
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.descriptionLabel
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0];
        [self addConstraints:@[self.leftImageHeightConstraint, self.leftImageWidthConstraint, leftDescriptionIconLeftConstaint, leftDescriptionIconVerticalCenterConstaint]];
        
        // description label
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.descriptionToLineConstraint =
        [NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.line
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:4];
        NSLayoutConstraint *descriptionLabelBottomConstaint =
        [NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0];
        self.descriptionLabelLeftConstraint =
        [NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.leftDescriptionIcon
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:8];
        self.descriptionLabelRightConstraint =
        [NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.rightDescriptionIcon
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:-8];
        [self addConstraints:@[self.descriptionToLineConstraint, descriptionLabelBottomConstaint, self.descriptionLabelLeftConstraint, self.descriptionLabelRightConstraint]];
        
        // right icon
        self.rightDescriptionIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightImageHeightConstraint =
        [NSLayoutConstraint constraintWithItem:self.rightDescriptionIcon
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:18];
        self.rightImageWidthConstraint =
        [NSLayoutConstraint constraintWithItem:self.rightDescriptionIcon
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:18];
        NSLayoutConstraint *rightDescriptionIconLeftConstaint =
        [NSLayoutConstraint constraintWithItem:self.rightDescriptionIcon
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *rightDescriptionIconVerticalCenterConstaint =
        [NSLayoutConstraint constraintWithItem:self.rightDescriptionIcon
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.descriptionLabel
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.0
                                      constant:0];
        [self addConstraints:@[self.rightImageHeightConstraint, self.rightImageWidthConstraint, rightDescriptionIconLeftConstaint, rightDescriptionIconVerticalCenterConstaint]];
        
        hasSetuped = YES;
    }
}

- (void)updateUI {
    if (self.textFieldState == SKFormTextFieldStateDefault) {
        self.line.backgroundColor = self.lineNormalColor;
    } else if (self.textFieldState == SKFormTextFieldStateActive) {
        self.line.backgroundColor = self.lineActiveColor;
    }
    
    self.textField.placeholder = self.placeholderText;
    self.textView.placeholderText = self.placeholderText;
    
    if (self.leftButtonImage) {
        [self.leftButton setImage:self.leftButtonImage forState:UIControlStateNormal];
    }
    if (self.rightButtonImage) {
        [self.rightButton setImage:self.rightButtonImage forState:UIControlStateNormal];
    }
    
    if (self.leftIconImage) {
        self.leftDescriptionIcon.image = self.leftIconImage;
    }
    if (self.rightIconImage) {
        self.rightDescriptionIcon.image = self.rightIconImage;
    }
    
    if (self.leftButtonHidden) {
        [self hideButtonAtSide:SKFormTextFieldSideLeft];
    } else {
        [self showButtonAtSide:SKFormTextFieldSideLeft];
    }
    if (self.rightButtonHidden) {
        [self hideButtonAtSide:SKFormTextFieldSideRight];
    } else {
        [self showButtonAtSide:SKFormTextFieldSideRight];
    }
    if (self.leftIconHidden) {
        [self hideDescriptionIconAtSide:SKFormTextFieldSideLeft];
    } else {
        [self showDescriptionIconAtSide:SKFormTextFieldSideLeft];
    }
    if (self.rightIconHidden) {
        [self hideDescriptionIconAtSide:SKFormTextFieldSideRight];
    } else {
        [self showDescriptionIconAtSide:SKFormTextFieldSideRight];
    }
    
    self.textFieldHeightConstraint.constant = self.textViewHeight;
    
    [self checkTextFieldState];
    
    if (self.mode == SKFormTextFieldModeRead) {
        if (self.type == SKFormTextFieldTypeTextField) {
            self.textField.userInteractionEnabled = false;
        } else if (self.type == SKFormTextFieldTypeTextFieldDate) {
            self.textField.userInteractionEnabled = false;
        } else if (self.type == SKFormTextFieldTypeTextView) {
            self.textView.userInteractionEnabled = false;
        }
        
        if (!self.doNotHideLineWhenRead) {
            self.lineHeightConstraint.constant = 0;
        }
        
        self.line.hidden = !self.doNotHideLineWhenRead;
    } else {
        if (self.type == SKFormTextFieldTypeTextField) {
            self.textField.userInteractionEnabled = true;
        } else if (self.type == SKFormTextFieldTypeTextFieldDate) {
            self.textField.userInteractionEnabled = true;
        } else if (self.type == SKFormTextFieldTypeTextView) {
            self.textView.userInteractionEnabled = true;
        }
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    [self updateUI];
}

- (void)checkTextFieldState {
    if (self.textFieldState == SKFormTextFieldStateActive) {
        // set description text to normal
        self.descriptionLabel.textColor = self.descriptionActiveColor;
        self.descriptionLabel.text = self.descriptionText;
        
        // set line to active state
        self.line.backgroundColor = self.lineActiveColor;
        self.lineHeightConstraint.constant = (self.hideLine ? 0 : 2);
        
        // reduce margin between line and description to prevent description text from hiding
        self.descriptionToLineConstraint.constant = (self.hideLine ? 0 : 3);
        
        // show normal icon if available
        if (self.rightDescriptionIcon) {
            self.rightDescriptionIcon.image = self.rightIconImage;
            if (!self.rightIconHidden) {
                [self showDescriptionIconAtSide:SKFormTextFieldSideRight];
            } else {
                [self hideDescriptionIconAtSide:SKFormTextFieldSideRight];
            }
        }
    } else if (self.textFieldState == SKFormTextFieldStateValid) {
        // set description text to normal
        self.descriptionLabel.textColor = self.descriptionValidColor;
        self.descriptionLabel.text = self.descriptionText;
        
        // set line to normal state
        self.line.backgroundColor = self.lineNormalColor;
        self.lineHeightConstraint.constant = (self.hideLine ? 0 : 1);
        
        // reduce margin between line and description to prevent description text from hiding
        self.descriptionToLineConstraint.constant = (self.hideLine ? 0 : 4);
        
        // show normal icon if available
        if (self.rightDescriptionIcon) {
            self.rightDescriptionIcon.image = self.rightIconImage;
            if (!self.rightIconHidden) {
                [self showDescriptionIconAtSide:SKFormTextFieldSideRight];
            } else {
                [self hideDescriptionIconAtSide:SKFormTextFieldSideRight];
            }
        }
    } else if (self.textFieldState == SKFormTextFieldStateInvalid) {
        // set error message
        self.descriptionLabel.textColor = self.descriptionErrorColor;
        self.descriptionLabel.text = self.errorMessageText;
        
        // set line to normal state
        self.line.backgroundColor = self.lineErrorColor;
        self.lineHeightConstraint.constant = (self.hideLine ? 0 : 2);
        
        // reduce margin between line and description to prevent description text from hiding
        self.descriptionToLineConstraint.constant = (self.hideLine ? 0 : 3);
        
        // show error icon
        if (self.errorImage) {
            self.rightDescriptionIcon.image = self.errorImage;
            [self showDescriptionIconAtSide:SKFormTextFieldSideRight];
        } else {
            [self hideDescriptionIconAtSide:SKFormTextFieldSideRight];
        }
    } else {
        // set description text to normal
        self.descriptionLabel.textColor = self.descriptionNormalColor;
        self.descriptionLabel.text = self.descriptionText;
        
        // set line to normal state
        self.line.backgroundColor = self.lineNormalColor;
        self.lineHeightConstraint.constant = (self.hideLine ? 0 : 1);
        
        // reduce margin between line and description to prevent description text from hiding
        self.descriptionToLineConstraint.constant = (self.hideLine ? 0 : 4);
        
        // show normal icon if available
        if (self.rightDescriptionIcon) {
            self.rightDescriptionIcon.image = self.rightIconImage;
            if (!self.rightIconHidden) {
                [self showDescriptionIconAtSide:SKFormTextFieldSideRight];
            } else {
                [self hideDescriptionIconAtSide:SKFormTextFieldSideRight];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.descriptionLabel.preferredMaxLayoutWidth = self.descriptionLabel.frame.size.width;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
}

#pragma mark - Methods
#pragma mark -

- (void)setType:(SKFormTextFieldType)type animated:(BOOL)animated {
    self.type = type;
    
    if (animated) {
        if (type == SKFormTextFieldTypeTextField) {
            self.textView.hidden = YES;
            self.textField.hidden = NO;
            self.textField.inputView = nil;
        } else if (type == SKFormTextFieldTypeTextFieldDate) {
            self.textView.hidden = YES;
            self.textField.hidden = NO;
            self.textField.inputView = self.datePicker;
        } else if (type == SKFormTextFieldTypeTextView) {
            self.textField.hidden = YES;
            self.textView.hidden = NO;
        }
        
        [UIView animateWithDuration:0.345 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:0 animations:^{
            [self layoutIfNeeded];
        } completion:nil];
    } else {
        if (type == SKFormTextFieldTypeTextField) {
            self.textView.hidden = YES;
            self.textField.hidden = NO;
        } else if (type == SKFormTextFieldTypeTextFieldDate) {
            self.textView.hidden = YES;
            self.textField.hidden = NO;
            self.textField.inputView = self.datePicker;
        } else if (type == SKFormTextFieldTypeTextView) {
            self.textField.hidden = YES;
            self.textView.hidden = NO;
        }
    }
}

- (void)showButtonAtSide:(SKFormTextFieldSide)side {
    if (side == SKFormTextFieldSideBoth) {
        self.leftButton.hidden = NO;
        self.rightButton.hidden = NO;
        
        self.textFieldLeftConstraint.constant = 8;
        self.leftButtonWidthConstraint.constant = 24;
        self.leftButtonHeightConstraint.constant = 24;
        
        self.textFieldRightConstraint.constant = -8;
        self.rightButtonWidthConstraint.constant = 24;
        self.rightButtonHeightConstraint.constant = 24;
    } else if (side == SKFormTextFieldSideLeft) {
        self.leftButton.hidden = NO;
        
        self.textFieldLeftConstraint.constant = 8;
        self.leftButtonWidthConstraint.constant = 24;
        self.leftButtonHeightConstraint.constant = 24;
    } else if (side == SKFormTextFieldSideRight) {
        self.rightButton.hidden = NO;
        
        self.textFieldRightConstraint.constant = -8;
        self.rightButtonWidthConstraint.constant = 24;
        self.rightButtonHeightConstraint.constant = 24;
    }
}

- (void)hideButtonAtSide:(SKFormTextFieldSide)side {
    if (side == SKFormTextFieldSideBoth) {
        self.leftButton.hidden = YES;
        self.rightButton.hidden = YES;
        
        self.textFieldLeftConstraint.constant = 0;
        self.leftButtonWidthConstraint.constant = 0;
        self.leftButtonHeightConstraint.constant = 0;
        
        self.textFieldRightConstraint.constant = 0;
        self.rightButtonWidthConstraint.constant = 0;
        self.rightButtonHeightConstraint.constant = 0;
    } else if (side == SKFormTextFieldSideLeft) {
        self.leftButton.hidden = YES;
        
        self.textFieldLeftConstraint.constant = 0;
        self.leftButtonWidthConstraint.constant = 0;
        self.leftButtonHeightConstraint.constant = 0;
    } else if (side == SKFormTextFieldSideRight) {
        self.rightButton.hidden = YES;
        
        self.textFieldRightConstraint.constant = 0;
        self.rightButtonWidthConstraint.constant = 0;
        self.rightButtonHeightConstraint.constant = 0;
    }
}

- (void)showDescriptionIconAtSide:(SKFormTextFieldSide)side {
    if (side == SKFormTextFieldSideBoth) {
        self.leftDescriptionIcon.hidden = NO;
        self.rightDescriptionIcon.hidden = NO;
        
        self.descriptionLabelLeftConstraint.constant = 8;
        self.leftImageWidthConstraint.constant = 18;
        self.leftImageHeightConstraint.constant = 18;
        
        self.descriptionLabelRightConstraint.constant = -8;
        self.rightImageWidthConstraint.constant = 18;
        self.rightImageHeightConstraint.constant = 18;
    } else if (side == SKFormTextFieldSideLeft) {
        self.leftDescriptionIcon.hidden = NO;
        
        self.descriptionLabelLeftConstraint.constant = 8;
        self.leftImageWidthConstraint.constant = 18;
        self.leftImageHeightConstraint.constant = 18;
    } else if (side == SKFormTextFieldSideRight) {
        self.rightDescriptionIcon.hidden = NO;
        
        self.descriptionLabelRightConstraint.constant = -8;
        self.rightImageWidthConstraint.constant = 18;
        self.rightImageHeightConstraint.constant = 18;
    }
}

- (void)hideDescriptionIconAtSide:(SKFormTextFieldSide)side {
    if (side == SKFormTextFieldSideBoth) {
        self.leftDescriptionIcon.hidden = YES;
        self.rightDescriptionIcon.hidden = YES;
        
        self.descriptionLabelLeftConstraint.constant = 0;
        self.leftImageWidthConstraint.constant = 0;
        self.leftImageHeightConstraint.constant = 0;
        
        self.descriptionLabelRightConstraint.constant = 0;
        self.rightImageWidthConstraint.constant = 0;
        self.rightImageHeightConstraint.constant = 0;
    } else if (side == SKFormTextFieldSideLeft) {
        self.leftDescriptionIcon.hidden = YES;
        
        self.descriptionLabelLeftConstraint.constant = 0;
        self.leftImageWidthConstraint.constant = 0;
        self.leftImageHeightConstraint.constant = 0;
    } else if (side == SKFormTextFieldSideRight) {
        self.rightDescriptionIcon.hidden = YES;
        
        self.descriptionLabelRightConstraint.constant = 0;
        self.rightImageWidthConstraint.constant = 0;
        self.rightImageHeightConstraint.constant = 0;
    }
}

- (BOOL)isEmpty {
    return !self.textField.text || self.textField.text.length == 0;
}

- (void)datePickerDidChange:(UIDatePicker *)datePicker {
    self.textField.text = [self.dateFormatter stringFromDate:datePicker.date];
}

#pragma mark - Protocols
#pragma mark -

- (BOOL)textFieldIsValid {
    if ([self.dataSource respondsToSelector:@selector(textFieldIsValid:)]) {
        if (self.required && (!self.textField.text || self.textField.text.length == 0)) {
            return NO;
        }
        return [self.dataSource textFieldIsValid:self];
    }
    if (self.required && (!self.textField.text || self.textField.text.length == 0)) {
        return NO;
    }
    
    return YES;
}

- (void)configureTextFieldForCurrentState {
    if ([self.dataSource respondsToSelector:@selector(configureTextField:forState:)]) {
        [self.dataSource configureTextField:self forState:self.textFieldState];
    }
    
    [self checkTextFieldState];
}

#pragma mark - UITextFieldDelegate Observers
#pragma mark -

- (void)textFieldDidChange:(UITextField *)textField {
    
    //[self setLabelOriginForTextAlignment];
    [self setNeedsLayout];
    
    CGSize floatingLabelSize = [_floatingLabel sizeThatFits:_floatingLabel.superview.bounds.size];
    
    _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                      _floatingLabel.frame.origin.y,
                                      floatingLabelSize.width,
                                      floatingLabelSize.height);
    
    BOOL firstResponder = textField.isFirstResponder;
    _floatingLabel.textColor = (firstResponder && textField.text && textField.text.length > 0 ?
                                self.labelActiveColor : self.floatingLabelTextColor);
    
    if ((!textField.text || 0 == [textField.text length]) && !self.alwaysShowFloatingLabel) {
        [self hideFloatingLabel:firstResponder];
    }
    else {
        [self showFloatingLabel:firstResponder];
    }
}

- (void)textFieldDidBeginEditing:(NSNotification *)notification {
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginUpdates:)]) {
        [self.delegate textFieldDidBeginUpdates:self];
    }
    
    UITextField *textField = [notification object];
    
    if (self.textField == textField) {
        self.textFieldState = SKFormTextFieldStateActive;
        [self configureTextFieldForCurrentState];
    }
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndUpdates:)]) {
        [self.delegate textFieldDidEndUpdates:self];
    }
}

- (void)textFieldDidEndEditing:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginUpdates:)]) {
        [self.delegate textFieldDidBeginUpdates:self];
    }
    
    UITextField *textField = [notification object];
    
    if (self.textField == textField) {
        self.textFieldState = [self textFieldIsValid] ? SKFormTextFieldStateValid : SKFormTextFieldStateInvalid;
        [self configureTextFieldForCurrentState];
        
        if (self.textFieldDidEndEditingBlock) {
            self.textFieldDidEndEditingBlock(textField.text);
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndUpdates:)]) {
        [self.delegate textFieldDidEndUpdates:self];
    }
}

#pragma mark - UITextViewDelegate Observers
#pragma mark -

- (void)textViewDidBeginEditing:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginUpdates:)]) {
        [self.delegate textFieldDidBeginUpdates:self];
    }
    
    UITextView *textView = [notification object];
    
    if (self.textView == textView) {
        self.textFieldState = SKFormTextFieldStateActive;
        [self configureTextFieldForCurrentState];
    }
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndUpdates:)]) {
        [self.delegate textFieldDidEndUpdates:self];
    }
}

- (void)textViewDidEndEditing:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginUpdates:)]) {
        [self.delegate textFieldDidBeginUpdates:self];
    }
    
    UITextView *textView = [notification object];
    
    if (self.textView == textView) {
        self.textFieldState = [self textFieldIsValid] ? SKFormTextFieldStateValid : SKFormTextFieldStateInvalid;
        [self configureTextFieldForCurrentState];
        
        if (self.textViewDidEndEditingBlock) {
            self.textViewDidEndEditingBlock(textView.text);
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndUpdates:)]) {
        [self.delegate textFieldDidEndUpdates:self];
    }
}

#pragma mark - Getters/Setters

- (void)setLineNormalColor:(UIColor *)lineNormalColor {
    _lineNormalColor = lineNormalColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setLineActiveColor:(UIColor *)lineActiveColor {
    _lineActiveColor = lineActiveColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setLineValidColor:(UIColor *)lineValidColor {
    _lineValidColor = lineValidColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setLineErrorColor:(UIColor *)lineErrorColor {
    _lineErrorColor = lineErrorColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setDescriptionNormalColor:(UIColor *)descriptionNormalColor {
    _descriptionNormalColor = descriptionNormalColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setDescriptionActiveColor:(UIColor *)descriptionActiveColor {
    _descriptionActiveColor = descriptionActiveColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setDescriptionValidColor:(UIColor *)descriptionValidColor {
    _descriptionValidColor = descriptionValidColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setDescriptionErrorColor:(UIColor *)descriptionErrorColor {
    _descriptionErrorColor = descriptionErrorColor;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = placeholderText;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setDescriptionText:(NSString *)descriptionText {
    _descriptionText = descriptionText;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setErrorMessageText:(NSString *)errorMessageText {
    _errorMessageText = errorMessageText;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setLeftButtonImage:(UIImage *)leftButtonImage {
    _leftButtonImage = leftButtonImage;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setRightButtonImage:(UIImage *)rightButtonImage {
    _rightButtonImage = rightButtonImage;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setLeftIconImage:(UIImage *)leftIconImage {
    _leftIconImage = leftIconImage;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setRightIconImage:(UIImage *)rightIconImage {
    _rightIconImage = rightIconImage;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setErrorImage:(UIImage *)errorImage {
    _errorImage = errorImage;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setLeftButtonHidden:(BOOL)leftButtonHidden {
    _leftButtonHidden = leftButtonHidden;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setRightButtonHidden:(BOOL)rightButtonHidden {
    _rightButtonHidden = rightButtonHidden;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setLeftIconHidden:(BOOL)leftIconHidden {
    _leftIconHidden = leftIconHidden;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setRightIconHidden:(BOOL)rightIconHidden {
    _rightIconHidden = rightIconHidden;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setTextViewHeight:(CGFloat)textViewHeight {
    _textViewHeight = textViewHeight;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setTextFieldState:(SKFormTextFieldState)textFieldState {
    _textFieldState = textFieldState;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setType:(SKFormTextFieldType)type {
    _type = type;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setMode:(SKFormTextFieldMode)mode {
    _mode = mode;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

- (void)setDoNotHideLineWhenRead:(BOOL)doNotHideLineWhenRead {
    _doNotHideLineWhenRead = doNotHideLineWhenRead;
    
    if (hasSetuped) {
        [self updateUI];
    }
}

#pragma mark - TEXTFIELD TITLE -

#pragma mark -

- (UIFont *)defaultFloatingLabelFont
{
    UIFont *textFieldFont = nil;
    
    if (!textFieldFont && self.textField.attributedPlaceholder && self.textField.attributedPlaceholder.length > 0) {
        textFieldFont = [self.textField.attributedPlaceholder attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont && self.textField.attributedText && self.textField.attributedText.length > 0) {
        textFieldFont = [self.textField.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont) {
        textFieldFont = self.textField.font;
    }
    
    return [UIFont fontWithName:textFieldFont.fontName size:roundf(textFieldFont.pointSize * 0.7f)];
}

- (void)updateDefaultFloatingLabelFont
{
    UIFont *derivedFont = [self defaultFloatingLabelFont];
    
    if (_isFloatingLabelFontDefault) {
        self.floatingLabelFont = derivedFont;
    }
    else {
        // dont apply to the label, just store for future use where floatingLabelFont may be reset to nil
        _floatingLabelFont = derivedFont;
    }
}

- (UIColor *)labelActiveColor
{
    if (_floatingLabelActiveTextColor) {
        return _floatingLabelActiveTextColor;
    }
    else if ([self respondsToSelector:@selector(tintColor)]) {
        return [self performSelector:@selector(tintColor)];
    }
    return [UIColor blueColor];
}

- (void)setFloatingLabelFont:(UIFont *)floatingLabelFont
{
    if (floatingLabelFont != nil) {
        _floatingLabelFont = floatingLabelFont;
    }
    _floatingLabel.font = _floatingLabelFont ? _floatingLabelFont : [self defaultFloatingLabelFont];
    _isFloatingLabelFontDefault = floatingLabelFont == nil;
    [self setFloatingLabelText:self.textField.placeholder];
    [self invalidateIntrinsicContentSize];
}

- (void)showFloatingLabel:(BOOL)animated
{
    void (^showBlock)() = ^{
        _floatingLabel.alpha = 1.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                          -12.0f,
                                          _floatingLabel.frame.size.width,
                                          _floatingLabel.frame.size.height);
    };
    
    if (animated || 0 != _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelShowAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:showBlock
                         completion:nil];
    }
    else {
        showBlock();
    }
}

- (void)hideFloatingLabel:(BOOL)animated
{
    void (^hideBlock)() = ^{
        _floatingLabel.alpha = 0.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                          _floatingLabel.font.lineHeight + _placeholderYPadding,
                                          _floatingLabel.frame.size.width,
                                          _floatingLabel.frame.size.height);
        
    };
    
    if (animated || 0 != _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelHideAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:hideBlock
                         completion:nil];
    }
    else {
        hideBlock();
    }
}

- (void)setLabelOriginForTextAlignment
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    
    CGFloat originX = textRect.origin.x;
    
    if (self.textField.textAlignment == NSTextAlignmentCenter) {
        originX = textRect.origin.x + (textRect.size.width/2) - (_floatingLabel.frame.size.width/2);
    }
    else if (self.textField.textAlignment == NSTextAlignmentRight) {
        originX = textRect.origin.x + textRect.size.width - _floatingLabel.frame.size.width;
    }
    
    _floatingLabel.frame = CGRectMake(originX + _floatingLabelXPadding, _floatingLabel.frame.origin.y,
                                      _floatingLabel.frame.size.width, _floatingLabel.frame.size.height);
}

- (void)setFloatingLabelText:(NSString *)text
{
    _floatingLabel.text = text;
    [self setLabelOriginForTextAlignment];
}

#pragma mark - UITextField

- (void)setFont:(UIFont *)font
{
    [self.textField setFont:font];
    [self updateDefaultFloatingLabelFont];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [self.textField setAttributedText:attributedText];
    [self updateDefaultFloatingLabelFont];
}

- (CGSize)intrinsicContentSize
{
    CGSize textFieldIntrinsicContentSize = [super intrinsicContentSize];
    [_floatingLabel sizeToFit];
    return CGSizeMake(textFieldIntrinsicContentSize.width,
                      textFieldIntrinsicContentSize.height - 12.0f + _floatingLabel.bounds.size.height);
}

- (void)setCorrectPlaceholder:(NSString *)placeholder
{
    if (self.placeholderColor && placeholder) {
        NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                                    attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
        [self.textField setAttributedPlaceholder:attributedPlaceholder];
    } else {
        [self.textField setPlaceholder:placeholder];
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [self setCorrectPlaceholder:placeholder];
    [self setFloatingLabelText:placeholder];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    [self.textField setAttributedPlaceholder:attributedPlaceholder];
    [self setFloatingLabelText:attributedPlaceholder.string];
    [self updateDefaultFloatingLabelFont];
}

- (void)setPlaceholder:(NSString *)placeholder floatingTitle:(NSString *)floatingTitle
{
    [self setCorrectPlaceholder:placeholder];
    [self setFloatingLabelText:floatingTitle];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder floatingTitle:(NSString *)floatingTitle
{
    [self.textField setAttributedPlaceholder:attributedPlaceholder];
    [self setFloatingLabelText:floatingTitle];
}

- (void)setPlaceholderColor:(UIColor *)color
{
    _placeholderColor = color;
    [self setCorrectPlaceholder:self.textField.placeholder];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [self.textField textRectForBounds:bounds];
    if ([self.textField.text length] || self.keepBaseline) {
        rect = [self insetRectForBounds:rect];
    }
    return CGRectIntegral(rect);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [self.textField editingRectForBounds:bounds];
    if ([self.textField.text length] || self.keepBaseline) {
        rect = [self insetRectForBounds:rect];
    }
    return CGRectIntegral(rect);
}

- (CGRect)insetRectForBounds:(CGRect)rect
{
    CGFloat topInset = ceilf(_floatingLabel.bounds.size.height + _placeholderYPadding);
    topInset = MIN(topInset, [self maxTopInset]);
    return CGRectMake(rect.origin.x, rect.origin.y + topInset / 2.0f, rect.size.width, rect.size.height);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect rect = [self.textField clearButtonRectForBounds:bounds];
    if (0 != self.adjustsClearButtonRect
        && _floatingLabel.text.length // for when there is no floating title label text
        ) {
        if ([self.textField.text length] || self.keepBaseline) {
            CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
            topInset = MIN(topInset, [self maxTopInset]);
            rect = CGRectMake(rect.origin.x, rect.origin.y + topInset / 2.0f, rect.size.width, rect.size.height);
        }
    }
    return CGRectIntegral(rect);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [self.textField leftViewRectForBounds:bounds];
    
    CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
    topInset = MIN(topInset, [self maxTopInset]);
    rect = CGRectOffset(rect, 0, topInset / 2.0f);
    
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    
    CGRect rect = [self.textField rightViewRectForBounds:bounds];
    
    CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
    topInset = MIN(topInset, [self maxTopInset]);
    rect = CGRectOffset(rect, 0, topInset / 2.0f);
    
    return rect;
}

- (CGFloat)maxTopInset
{
    return MAX(0, floorf(self.textField.bounds.size.height - self.textField.font.lineHeight - 4.0f));
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [self.textField setTextAlignment:textAlignment];
    [self setNeedsLayout];
}

- (void)setAlwaysShowFloatingLabel:(BOOL)alwaysShowFloatingLabel
{
    _alwaysShowFloatingLabel = alwaysShowFloatingLabel;
    [self setNeedsLayout];
}

- (void)prepareTextFieldTitleForAttributes:(NSDictionary *)attr {
    [self setFloatingLabelFont:[attr valueForKey:NSFontAttributeName]];
    [self setFloatingLabelTextColor:[attr valueForKey:NSForegroundColorAttributeName]];
}

- (void)showTextFieldTitle {
    if (_floatingLabel.alpha < 1.0f) {
        [self showFloatingLabel:YES];
    }
}

- (void)hideTextFieldTitle {
    if (_floatingLabel.alpha > 0.0f) {
        [self hideFloatingLabel:YES];
    }
}

@end
