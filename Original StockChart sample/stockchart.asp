<%@ Language=JavaScript %>
<%

//
// Copyright ©2001 Cisco Systems Inc. All rights reserved.
//
// File:    stockchart.asp
// Author:  DAD
// Purpose: Uses the CiscoURLProxy and the CipImage Library to get and .gif file from the internet,
//					convert it to a .cip image. modify it, and return it to the requestor.
//          
//

try
	{
	var Inet1 = new ActiveXObject("CiscoURLProxy.URLGrabber");               // Create the proxy object
	var rawdata = Inet1.GetURL("http://ichart.yahoo.com/t?s=csco", 1);           // Get the gif from Yahoo... Note the "1" as the second parameter tells the component ByteArray. Its in the proxy doc...
	var cip = new ActiveXObject("CIPIMAGE.ImageProcessor.1");                // Create my cip object
	var serverIP = Request.ServerVariables("LOCAL_ADDR");
	var d = new Date();
	var hour = d.getHours();
	var chartarray = new Array();

	cip.LoadPNGFromBuffer(rawdata);	                                         // Load the byte array
	cip.RGBToPalette();                                                      // I don't know if the source is RGB or a palette so I to this anyway. It doesn't hurt...
	cip.ColorToGray();                                                       // reduce the colors to grayscale
	cip.ReducePaletteColors(4);                                              // reduce the palette to 4 colors. (2-bit)

	var rawchartdata = cip.SaveCIPDataToBuffer();

	Response.Buffer = true;	
	Response.ContentType = "text/xml";                                       // Don't forget the xml mime type header we all love...
	Response.Write("<CiscoIPPhoneImage>\r\n<LocationX>-1</LocationX>\r\n<LocationY>-1</LocationY>\r\n<Width>132</Width>\r\n<Height>64</Height>\r\n<Depth>2</Depth>\r\n<Data>");

	
	for (var i = 0; i < 96; i++)
		{
		chartarray[i] = String(rawchartdata).substr(i * 96, 96);
		}

	for (var i = 13; i < 77; i++)
		{
		Response.Write(String(chartarray[i]).substr(2, 20)); // Show Numbers
		
		hour = d.getHours();
		
		if (Number(hour) < 13) // If before 1:00pm show left side of graph
			{
			Response.Write(String(chartarray[i]).substr(22, 42));
			}
		else if (Number(hour) < 14) // If after 1:00 pm and before 2:00pm show left side of graph
			{
			Response.Write(String(chartarray[i]).substr(32, 42));
			}
		else if (Number(hour) < 15) // If after 2:00 pm and before 3:00pm show left side of graph
			{
			Response.Write(String(chartarray[i]).substr(42, 42));
			}
		else // after 3:00pm show right side of graph
			{
			Response.Write(String(chartarray[i]).substr(46, 42));	
			}
		
		Response.Write(String(chartarray[i]).substr(90, 4));
		}

	Response.Write("</Data>\r\n<Prompt>CSCO Intra-day Chart</Prompt></CiscoIPPhoneImage>\r\n");

	Response.Flush(); // Flush by bufferd response 
	}
catch (err)
	{
	Response.Write("Error: " + err.description + ", " + err.number.toString(16)); // Yeah right, we won't have any errors....
	} 
 Response.End();


//  THIS SAMPLE APPLICATION AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND BY CISCO, 
//  EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY
//  FITNESS FOR A PARTICULAR PURPOSE, NONINFRINGEMENT, SATISFACTORY QUALITY OR ARISING FROM A COURSE
//  OF DEALING, LAW, USAGE, OR TRADE PRACTICE.  CISCO TAKES NO RESPONSIBILITY REGARDING ITS USAGE IN AN
//  APPLICATION., THE APPLICATION IS PROVIDED AS AN EXAMPLE ONLY, THEREFORE CISCO DOES NOT MAKE ANY
//  REPRESENTATIONS REGARDING ITS RELIABILITY, SERVICEABILITY, OR FUNCTION.  IN NO EVENT DOES CISCO
//  WARRANT THAT THE SOFTWARE IS ERROR FREE OR THAT CUSTOMER WILL BE ABLE TO OPERATE THE SOFTWARE WITHOUT
//  PROBLEMS OR INTERRUPTIONS.  NOR DOES CISCO WARRANT THAT THE SOFTWARE OR ANY EQUIPMENT ON WHICH THE
//  SOFTWARE IS USED WILL BE FREE OF VULNERABILITY TO INTRUSION OR ATTACK.  THIS SAMPLE APPLICATION IS
//  NOT SUPPORTED BY CISCO IN ANY MANNER. CISCO DOES NOT ASSUME ANY LIABILITY ARISING FROM THE USE OF THE
//  APPLICATION. FURTHERMORE, IN NO EVENT SHALL CISCO OR ITS SUPPLIERS BE LIABLE FOR ANY INCIDENTAL OR
//  CONSEQUENTIAL DAMAGES, LOST PROFITS, OR LOST DATA, OR ANY OTHER INDIRECT DAMAGES EVEN IF CISCO OR ITS
//  SUPPLIERS HAVE BEEN INFORMED OF THE POSSIBILITY THEREOF.

 %>