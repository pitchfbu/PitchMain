//
//  EventDetailsViewController.m
//  Pitch
//
//  Created by sbernal0115 on 7/25/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "CustomCollectionViewCell.h"
#import "DataHandling.h"
#import "UIImageView+AFNetworking.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EventDetailsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) DataHandling *dataHandlingObject;
@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    self.testingVibes = @[@"Vibe1",@"Vibe2",@"Vibe3"];
    self.dataHandlingObject = [DataHandling shared];
    [self.eventNameLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
    [self configureBaseViewsAndImage];
    [self createRegisterButton];
    [self createVibesLabelAndVibesCollection];
    [self createDistanceLabel];
    [self createdAttendanceCountLabel];
    [self createAgeRestrictionLabel];
}

- (void)configureBaseViewsAndImage {
    self.scrollViewOutlet.clipsToBounds = YES;
    self.eventNameViewOutlet.layer.cornerRadius = 30;
    self.swipeIndicatorOutlet.layer.cornerRadius = self.swipeIndicatorOutlet.frame.size.height/2;
    self.eventNameViewOutlet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;;
    [self.scrollViewOutlet setShowsVerticalScrollIndicator:NO];
    self.scrollViewOutlet.contentSize = CGSizeMake(self.view.frame.size.width, self.roundedCornersViewOutlet.frame.size.height + 500);
    [self.scrollViewOutlet setBackgroundColor: UIColorFromRGB(0x21ce99)];
    [self.swipeIndicatorOutlet setBackgroundColor:[UIColor lightGrayColor]];
    [self.eventNameViewOutlet setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    self.roundedCornersViewOutlet.backgroundColor = UIColorFromRGB(0x21ce99);
    self.scrollViewOutlet.contentInsetAdjustmentBehavior = 2;
    [super viewDidLoad];
    UITapGestureRecognizer *tapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [self.clickableMapViewOutlet addGestureRecognizer:tapMap];
    UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTabBarModal:)];
    [downGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.eventNameViewOutlet addGestureRecognizer: downGestureRecognizer];
    self.eventNameLabel.text = self.event.eventName;
    NSURL *imageNSURL = [NSURL URLWithString:self.event.eventImageURLString];
    [self.eventImageView setImageWithURL:imageNSURL];
}

- (void)createRegisterButton {
    self.registerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 90, self.eventImageView.frame.size.height + 20, 180, 40)];
    if ([self.event.registeredUsersArray containsObject:[FIRAuth auth].currentUser.uid]) {
        [self.registerButton setTitle:@"Registered" forState:UIControlStateNormal];
        [self.registerButton setBackgroundColor:[UIColor lightGrayColor]];
    } else {
        [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
        [self.registerButton setBackgroundColor: UIColorFromRGB(0xf5f5f5)];
    }
    [self.registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.registerButton.layer.cornerRadius = self.registerButton.frame.size.height/2;
    [self.registerButton.titleLabel  setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:25]];
    self.registerButton.alpha = 1;
    [self.registerButton setEnabled:YES];
    [self.registerButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.roundedCornersViewOutlet addSubview:self.registerButton];
}

-(void)createVibesLabelAndVibesCollection
{
    self.vibesLabel = [[UILabel alloc] initWithFrame: CGRectMake(30, self.registerButton.frame.origin.y + self.registerButton.frame.size.height + 20, 40,20)];
    [self.vibesLabel setText:@"Vibes/Themes:"];
    [self.vibesLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.vibesLabel sizeToFit];
    [self.vibesLabel setRestorationIdentifier:@"vibesLabel"];
    [self.roundedCornersViewOutlet addSubview:self.vibesLabel];
    self.vibesCollectionView.delegate = self;
    self.vibesCollectionView.dataSource = self;
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(50, 50);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.vibesCollectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CustomCollectionViewCell"];
    [self.vibesCollectionView setAllowsSelection:NO];
    CGRect frameForCollectionView = CGRectMake(self.vibesLabel.frame.origin.x, self.vibesLabel.frame.origin.y + self.vibesLabel.frame.size.height + 10, self.view.frame.size.width - self.vibesLabel.frame.origin.x * 2, 30);
    self.vibesCollectionView = [[UICollectionView alloc] initWithFrame:frameForCollectionView collectionViewLayout:flowLayout];
    self.vibesCollectionView.layer.cornerRadius = self.vibesCollectionView.frame.size.height/2;
    [self.roundedCornersViewOutlet addSubview:self.vibesCollectionView];
    [self.vibesCollectionView setFrame:frameForCollectionView];
}

-(void)createDistanceLabel
{
    self.distanceFromUserLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.vibesLabel.frame.origin.x, self.vibesCollectionView.frame.origin.y+self.vibesCollectionView.frame.size.height + 20, 100, 20)];
    [self.distanceFromUserLabel setText:[NSString stringWithFormat:@"Distance From You: %d", self.distanceFromUserInt]];
    [self.distanceFromUserLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.distanceFromUserLabel sizeToFit];
    [self.distanceFromUserLabel setRestorationIdentifier:@"distanceFromUserLabel"];
    [self.roundedCornersViewOutlet addSubview:self.distanceFromUserLabel];
}

-(void)createdAttendanceCountLabel
{
    self.attendanceCountLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.distanceFromUserLabel.frame.origin.x, self.distanceFromUserLabel.frame.origin.y+self.distanceFromUserLabel.frame.size.height + 20, 100, 50)];
    [self.attendanceCountLabel setText:[NSString stringWithFormat:@"Attendance: %d", self.eventAttendancCountInt]];
    [self.attendanceCountLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.attendanceCountLabel sizeToFit];
    [self.attendanceCountLabel setRestorationIdentifier:@"attendanceCountLabel"];
    [self.roundedCornersViewOutlet addSubview:self.attendanceCountLabel];
}

-(void)createAgeRestrictionLabel
{
    self.ageRestrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.attendanceCountLabel.frame.origin.x, self.attendanceCountLabel.frame.origin.y+self.attendanceCountLabel.frame.size.height + 20, 100, 20)];
    [self.ageRestrictionLabel setText:[NSString stringWithFormat:@"Age Restriction: %d", self.eventAgeRestrictionInt]];
    [self.ageRestrictionLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    [self.ageRestrictionLabel sizeToFit];
    [self.ageRestrictionLabel setRestorationIdentifier:@"ageRestrictionLabel"];
    [self.roundedCornersViewOutlet addSubview:self.ageRestrictionLabel];
    [self.ageRestrictionLabel.bottomAnchor constraintEqualToAnchor:self.roundedCornersViewOutlet.bottomAnchor constant:-10.0].active = YES;
}


- (void)registerButtonPressed {
    if ([self.registerButton.titleLabel.text isEqualToString:@"Register"]){
        [self.registerButton setSelected:YES];
        [self.registerButton setTitle:@"Registered" forState:UIControlStateNormal];
        self.eventAttendancCountInt += 1;
        [[DataHandling shared] registerUserToEvent:self.event];
        [self.registerButton setBackgroundColor:[UIColor lightGrayColor]];
        NSLog(@"Registered user; now in registered users array");
    } else {
        [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
        self.eventAttendancCountInt -= 1;
        [[DataHandling shared] unregisterUser:self.event];
        [self.registerButton setBackgroundColor: UIColorFromRGB(0xf5f5f5)];
        NSLog(@"Unregistered user; now not in registered users array");
    }
    [self.attendanceCountLabel setText:[NSString stringWithFormat:@"Attendance: %d", self.eventAttendancCountInt]];
}

- (void)dismissTabBarModal:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [self.vibesCollectionView dequeueReusableCellWithReuseIdentifier:@"CustomCollectionViewCell" forIndexPath:indexPath];
    [cell setLabelText:self.testingVibes[indexPath.item]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.testingVibes.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"CustomCollectionViewCell" owner:self options:nil].firstObject;
    [cell setLabelText:self.testingVibes[indexPath.row]];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return CGSizeMake(size.width, 30);
}

- (void)checkForUserRegistrationDelegateMethod:(BOOL)registerValue {
    self.registrationStatusForEvent = registerValue;
}


@end
