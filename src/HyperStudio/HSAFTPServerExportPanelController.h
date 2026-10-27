#import "HyperStudioPrefix.h"
#import "HSExportPanelController.h"
#import "HSANetworkConnection.h"


@interface HSAFTPServerExportPanelController : HSExportPanelController <HSANetworkConnectionDelegate>
{
    NSTextField *_ftpHostTextField;
    NSTextField *_directoryPathTextField;
    NSTextField *_httpHostTextField;
    NSTextField *_userTextField;
    NSTextField *_passwordTextField;
    NSTextField *_stackNameTextField;
    NSTextField *_portTextField;
    NSButton *_anonymousUserCheckBox;
    NSButton *_addPasswordToKeyChainCheckBox;
    NSButton *_cancelButton;
    NSButton *_publishButton;
    NSButton *_testConnectionButton;
    HSAFTPConnection *_connection;
    unsigned int _isResourceExistsChecking:1;
    unsigned int _areLinkedStacksInDocument:1;
}
- (id)windowNibName;
- (void)awakeFromNib;
- (void)controlTextDidChange:(id)aNotification;
- (id)connection;
- (void)setConnection:(id)aConnection;
- (id)loadPasswordFromKeyChain;
- (BOOL)savePasswordToKeyChain:(id)aPassword;
- (IBAction)anonymousUserChanged:(id)aSender;
- (IBAction)onTestConnection:(id)aSender;
- (IBAction)onPublish:(id)aSender;
- (IBAction)cancel:(id)aSender;
- (void)resourceExistsAlertDidEnd:(id)aAlert returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)connectionDidSucceed:(id)aConnection;
- (void)connection:(id)aConnection didFinishChecking:(id)aResult;
- (void)connection:(id)aConnection didFailWithError:(id)aError;
- (void)dealloc;
@end
