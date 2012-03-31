//
//  DownloadController.m
//  Reader
//
//  Created by Pedro Góes on 22/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadController.h"
#import "MasterViewController.h"
#import "XMLReader.h"


@implementation DownloadController

@synthesize fila;
@synthesize dadosRecebidos;
@synthesize delegate;

// Cria um Singleton para a classe
SYNTHESIZE_SINGLETON_FOR_CLASS(DownloadController);

#pragma mark -
#pragma mark Memory management

- (id) init {
    
    fila = [NSMutableArray arrayWithCapacity:1];
    
    return self;
}


#pragma mark -
#pragma mark User Methods

/*
 
 ESTRUTURA DO DICIONARIO DOS DOWNLOADS EM ESPERA:
 
 DOWNLOAD_URL: Url completa do arquivo a ser baixado
 DOWNLOAD_ARQUIVO: Nome do arquivo a ser baixado
 DOWNLOAD_CELULA: Célula para o valor da tag informada
 DOWNLOAD_TAG: Célula para o valor da tag informada
 DOWNLOAD_CACHE: Informa se é cache ou não
 
 
 */

- (BOOL)addURL:(NSString *)url savingAs:(NSString *)file {
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    [dic setValue:url forKey:DOWNLOAD_URL];
    [dic setValue:file forKey:DOWNLOAD_ARQUIVO];
    
    [fila insertObject:dic atIndex:0];
    
    [self updateInterfaceWithText:@"Aguardando término do download"];
    
    // Depois que a URL foi adicionada, podemos iniciar o download
    [self initDownload];
    
    return YES;
}

- (void)initDownload {
    // Checa se existe algum download sendo efetuado no momento
    if (baixando == YES) {
        return;
    }
    
    // Verifica se há algum arquivo para ser baixado
	if ([fila count] > 0) {
		
        // Obtém o ultimo objeto adicionado a lista (pilha)
        NSString * url = [[fila lastObject] objectForKey:DOWNLOAD_URL];
		
		// Criando a requisição
		NSURLRequest * theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
													 cachePolicy:NSURLRequestUseProtocolCachePolicy
												 timeoutInterval:20.0];
		
		// Cria a conexão a partir da requisição e passa a carregar os dados
		NSURLConnection * theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
		if (theConnection) {
			// Atualiza a flag informando que algum download está sendo efetuado e retém os dados
			baixando = YES;
			dadosRecebidos = [NSMutableData data];
            
            [self updateInterfaceWithText:@"Conexão iniciada"];
		} else {
            // Atualiza interface
            [self updateInterfaceWithText:@"Conexão falhou!"];
            [self performSelector:@selector(restaurarInterface) withObject:nil afterDelay:0.4];
        }
	} else {
        [self parseCache];
    }
}

- (void)cancelDownload {
    
}

- (void)updateInterfaceWithText:(NSString *)text {

}

- (void)restoreInterface {

}

- (void)parseCache {
    
    /*
    if (!delegate.menu) {
        delegate.menu = [[NSDictionary alloc] initWithCapacity:11];
    } else {
        [delegate.menu removeAllObjects];
    }
     */
    
    NSError *error = nil;
    
    // Loading the just download xml file
    NSString *xml = [NSString stringWithContentsOfFile:[[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent: CACHE_PADRAO_ARQUIVO] 
                                               encoding:NSISOLatin1StringEncoding
                                                  error:&error];
    
    delegate.menu = [XMLReader dictionaryForXMLString:xml error:&error];
    
    /*
    //NSLog(@"%@", html);
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *tdNodes = [bodyNode findChildTags:@"td"];
    
    for (HTMLNode *tdNode in tdNodes) {
        if ([[tdNode getAttributeNamed:@"class"] isEqualToString:@"menu"]) {
            
            NSLog(@"%@", [tdNode rawContents]);
            //NSLog(@"%@", [tdNode contents]);
            
            // Didn't find any reference to the days of the week
            if ([[tdNode contents] rangeOfString:@"feira"].location == NSNotFound) {
                
            }
            
            
            
            [delegate.menu addObject:nil];

            NSArray *tdChildren = [tdNode children];
            for (int i=0; i<22; i++) {
                
                if (i == 20) {
                    
                }
                
                //NSLog(@"%@", [[tdChildren objectAtIndex:i] contents]);
            }
        }
    }
    
    NSArray *spanNodes = [bodyNode findChildTags:@"span"];
    
    for (HTMLNode *spanNode in spanNodes) {
        if ([[spanNode getAttributeNamed:@"class"] isEqualToString:@"spantext"]) {
            NSLog(@"%@", [spanNode rawContents]); //Answer to second question
        }
    }
    */
    //[delegate carregarCache];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= 40302

#pragma mark -
#pragma mark Connection Support 4.3

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [dadosRecebidos setLength:0];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{    
    // Adiciona os dados recebidos a variável
    [dadosRecebidos appendData:data];
    
    [self atualizarInterfaceComProgresso:((float)[dadosRecebidos length] / (float)[[[fila lastObject] objectForKey:DOWNLOAD_TAMANHO] intValue])
                                comTexto:[NSString stringWithFormat:@"%d %%", (int) (100 * (float)[dadosRecebidos length] / (float)[[[fila lastObject] objectForKey:DOWNLOAD_TAMANHO] intValue])]
                                 comPath:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Libera os objetos
    [connection release];
    [dadosRecebidos release];
    
    // Atualiza interface
    CustomCell * celula = (CustomCell *)[delegate.tableView cellForRowAtIndexPath:[[fila lastObject] objectForKey:DOWNLOAD_PATH]];
    celula.porcentagemTexto.text = @"Download falhou!";
    [self performSelector:@selector(restaurarInterface) withObject:nil afterDelay:0.4];
    
    // Atualiza a flag pois o download falhou
	baixando = NO;
    
    // Inicia o próximo download
    [self iniciarDownload];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[dadosRecebidos length]);
	
	// Salvando array em arquivo
    NSString * caminho = [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"]
                          stringByAppendingPathComponent:[[fila lastObject] objectForKey:DOWNLOAD_ARQUIVO]];
	[dadosRecebidos writeToFile:caminho atomically:YES];
	
    // Libera os objetos
    [connection release];
    [dadosRecebidos release];
    
    // Atualiza interface
    CustomCell * celula = (CustomCell *)[delegate.tableView cellForRowAtIndexPath:[[fila lastObject] objectForKey:DOWNLOAD_PATH]];
    celula.porcentagemTexto.text = @"Download completo!";
    [self performSelector:@selector(restaurarInterface) withObject:nil afterDelay:0.4];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Remove o download completado da fila
    [fila removeLastObject];
    
    // Atualiza a flag pois o download terminou
	baixando = NO;
    
    // Informa a célula que o download terminou
    celula.estadoDownload = NO;
    
    // Inicia o próximo download
    [self iniciarDownload];
}

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000

#pragma mark -
#pragma mark Connection Support 5.0

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [dadosRecebidos setLength:0];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{  
    // Adiciona os dados recebidos a variável
    [dadosRecebidos appendData:data];
}
 

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    // Atualiza interface
    [self updateInterfaceWithText:@"Download falhou!"];
    [self performSelector:@selector(restoreInterface) withObject:nil afterDelay:0.4];
    
    // Atualiza a flag pois o download falhou
	baixando = NO;
    
    // Inicia o próximo download
    [self initDownload];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
    
	// Salvando array em arquivo
    NSString * caminho = [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"]
                          stringByAppendingPathComponent:[[fila lastObject] objectForKey:DOWNLOAD_ARQUIVO]];
	[dadosRecebidos writeToFile:caminho atomically:YES];

    // Atualiza interface
    [self updateInterfaceWithText:@"Download completo!"];
    [self restoreInterface];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Remove o download completado da fila
    [fila removeLastObject];
    
    // Atualiza a flag pois o download terminou
	baixando = NO;
    
    // Inicia o próximo download
    [self initDownload];
}

#endif



@end
