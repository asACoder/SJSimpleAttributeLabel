SJSimpleAttributeLabel
======================

一个简单的可以单行显示不同颜色文本的Label
------------


使用方法:
      SJAttributeLabel *label = [[SJAttributeLabel alloc] initWithFrame:CGRectMake(20, 200, 200, 40)];
      label.backgroundColor = [UIColor grayColor];
      label.textColor = [UIColor blackColor];
      label.alignment = SJAlignmentCenter;
      label.text = @"helloworldevery";
      [label addAttributes:@{kAttributeTextColor:[UIColor blueColor]} range:NSMakeRange(0, 5)];
      [label addAttributes:@{kAttributeTextColor:[UIColor greenColor]} range:NSMakeRange(5, 5)];
      [label addAttributes:@{kAttributeTextColor:[UIColor orangeColor]} range:NSMakeRange(10, 5)];
      
      [self.view addSubview:label]; 
