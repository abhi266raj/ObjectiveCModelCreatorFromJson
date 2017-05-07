#import <Foundation/Foundation.h>




@interface JSONModelCreater : NSObject


@property (nonatomic,strong) NSDictionary *dictionary;
@property (nonatomic,strong) NSString *modelName;


-(id)initWithDictionary:(NSDictionary*)dictionary andModelName:(NSString*)ModelName;
-(void)createModel;
@end



@implementation JSONModelCreater


-(id)initWithDictionary:(NSDictionary*)dictionary andModelName:(NSString*)modelName{
    self = [super init];
    if (self){
        self.dictionary = dictionary;
        self.modelName = [self fileNameAccordingToAlgorithm:modelName];
    }
    return self;
}


-(void)createModel{
    [self updateModelUsingDictionary:self.dictionary andModelName:self.modelName];
    
}


-(NSString*)fileNameAccordingToAlgorithm:(NSString*)string{
    return string;
}

-(bool)checkIfFileWithModelNameExists:(NSString*)string{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *currentpath = [fileManger currentDirectoryPath];
    NSString *pathh = [[NSString alloc]initWithFormat:@"%@/%@.h",currentpath,string];
    NSString *pathm = [[NSString alloc]initWithFormat:@"%@/%@.m",currentpath,string];
    return ([fileManger fileExistsAtPath:pathh] && [fileManger fileExistsAtPath:pathm]);
}


-(NSString *)pathForFilewithModelName:(NSString*)string{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString* currentpath = [fileManger currentDirectoryPath];
    NSString *path = [[NSString alloc]initWithFormat:@"%@/%@",currentpath,string];
    return path;
    
}

-(NSString*)pathForNewCreatedFileWithModelName:(NSString*)string{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *currentpath = [fileManager currentDirectoryPath];
    NSString *path = [[NSString alloc]initWithFormat:@"%@/%@",currentpath,string];
    NSString *pathh = [[NSString alloc]initWithFormat:@"%@/%@.h",currentpath,string];
    NSString *pathm = [[NSString alloc]initWithFormat:@"%@/%@.m",currentpath,string];
    [[NSFileManager defaultManager] createFileAtPath:pathm
                                            contents:nil
                                          attributes:nil];
    [[NSFileManager defaultManager] createFileAtPath:pathh
                                            contents:nil
                                          attributes:nil];
    
    
    return path;
    
}

-(void)updateModelUsingDictionary:(NSDictionary*)dictionary andModelName:(NSString*)string{
    
    NSString *modelName = [self fileNameAccordingToAlgorithm:string];
    NSString *pathForModelFile;
    if ([self checkIfFileWithModelNameExists:modelName]){
        pathForModelFile = [self pathForFilewithModelName:modelName];
    }else{
        pathForModelFile = [self pathForNewCreatedFileWithModelName:modelName];
        NSLog (@"Going to craete a file");
    }
    [self updateModelUsingDictionary:dictionary andFilePath:pathForModelFile];
    
    for (NSString* key in dictionary){
        id object = dictionary[key];
        NSLog (@"Class of object %@ , %@", key ,[object class]);
        if ([object isKindOfClass:[NSDictionary class]]){
            [self updateModelUsingDictionary:object  andModelName:key];
        }
    }
    
}


-(void)updateModelUsingDictionary:(NSDictionary*)dictionary andFilePath:(NSString*)filePath{
    NSMutableSet *set = [[NSMutableSet alloc]init];
    for (NSString* key in dictionary){
        id object = dictionary[key];
        NSLog (@"Set of object %@ , %@", key ,[object class]);
        [set addObject:[self stringToBeWrittenInFileForKey:key andValue:object]];
        //NSLog (@"%@",set);
    }
    [self appendItemOfSet:set inFilePath:filePath];
    
    
}


-(void)appendItemOfSet:(NSSet*)set inFilePath:(NSString*)filePath{
    NSMutableString *outputString ;
    for (NSString* item in set){
        if (!outputString){
            outputString = [[NSMutableString alloc ]initWithString:@"/*\nModel Created By Source Creator*/\n"];
        }else{
            [outputString appendString:@"\n"];
        }
        [outputString appendString:item];
    }
    
    
    
    NSLog (@"filePath = %@",filePath);
    //save content to the documents directory
    [outputString writeToFile:filePath
                   atomically:NO
                     encoding:NSStringEncodingConversionAllowLossy
                        error:nil];
    
    
}

-(NSString*)stringToBeWrittenInFileForKey:(NSString*)key andValue:(id)value{
    NSString *string = @"Error";
    Class itemClass = [value class];
    //isMemberOfClass
    
    NSLog (@"ItemClass %@",itemClass);
    if ([itemClass isSubclassOfClass:[NSString class]]){
         string = [[NSString alloc]initWithFormat:@"@property (nonatomic,strong) NSString * %@",key];
    }
    
    if ([itemClass isSubclassOfClass:[NSNumber class]]){
        string = [[NSString alloc]initWithFormat:@"@property (nonatomic,strong) NSNumber * %@",key];
    }
    
    if ([itemClass isSubclassOfClass:[NSDictionary class]]){
        string = [[NSString alloc]initWithFormat:@"@property (nonatomic,strong) NSDictionary * %@",key];
    }
    
    if ([itemClass isSubclassOfClass:[NSArray class]]){
        string = [[NSString alloc]initWithFormat:@"@property (nonatomic,strong) NSArray * %@",key];
    }
    
    if ([[value class ] isSubclassOfClass:[NSString class]]){
        NSLog (@"HEllo");
    }
    
//    if ([[value class] isSubclassOfClass:[NSString class]]){
//        NSLog (@"Sorry");
//    }
//    
//    
//    if ([[value class] isSubclassOfClass:[NSString class]]){
//        NSLog (@"W");
//    }
    return string;
}


@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString *fileName = @"ocassion.json";
        bool shouldUseTopLevel = false;
        NSFileManager *fileManger = [NSFileManager defaultManager];
        
        if (!fileManger){
            NSLog (@"Error path invalide");
        }
        NSString *currentpath;
        
        currentpath = [fileManger currentDirectoryPath];
        NSString *path = [[NSString alloc]initWithFormat:@"%@/%@",currentpath,fileName];
        NSLog (@"%@",path);
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data){
            NSMutableDictionary* jsonData = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                                          options:kNilOptions
                                                                                                                            error:nil]];
            
            JSONModelCreater *modelCreator = [[JSONModelCreater alloc]initWithDictionary:jsonData andModelName:@"try"];
            [modelCreator createModel];
            
            if (!jsonData){
                NSLog (@"Wrong foramt");
                return 0;
            }
        }else{
            NSLog (@"Error, not able to read the file");
        }
        
        
    }
    
    return 0;
}

