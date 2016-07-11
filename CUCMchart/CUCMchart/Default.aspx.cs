using CIPIMAGE;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CUCMchart
{
    public partial class Default : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
           // ResponseImage();
          //  Response.Redirect("IISchart1.ashx");
        }

        private void ResponseImage()
        {
            try
            {
                var grabber = new CiscoURLProxy.URLGrabber();// Create the proxy object
                var type = CiscoURLProxy.dataType.dtByteArray;
                var rawdata = grabber.GetURL("http://ichart.yahoo.com/t?s=csco", type);           // Get the gif from Yahoo... Note the "1" as the second parameter tells the component ByteArray. Its in the proxy doc...
                // var cip = new ImageProcessor();              // Create my cip object
                ImageProcessor cip = new ImageProcessor();

                cip.LoadPNGFromBuffer(rawdata);	                                         // Load the byte array
                cip.RGBToPalette();                                                      // I don't know if the source is RGB or a palette so I to this anyway. It doesn't hurt...
                cip.ColorToGray();                                                       // reduce the colors to grayscale
                cip.ReducePaletteColors(4);                                              // reduce the palette to 4 colors. (2-bit)
                var data = cip.SaveCIPToBuffer().ToString();
                var rawchartdata = cip.SaveCIPDataToBuffer();

                // var serverIP = Request.ServerVariables("LOCAL_ADDR");
                var date = DateTime.Now;
                var hour = DateTime.Now.Hour;
                var chartarray = new ArrayList();
                Response.Buffer = true;
                Response.ContentType = "text/xml"; // Don't forget the xml mime type header we all love...
                Response.Write(
                    "<CiscoIPPhoneImage>\r\n<LocationX>-1</LocationX>\r\n<LocationY>-1</LocationY>\r\n<Width>132</Width>\r\n<Height>64</Height>\r\n<Depth>2</Depth>\r\n<Data>");
                int count = rawchartdata.Length;

                for (var i = 0; i < 95; i++)
                {
                    chartarray.Add((rawchartdata).Substring(i * 95, 95));
                }

                for (var i = 13; i < 77; i++)
                {
                    Response.Write((chartarray[i]).ToString().Substring(2, 20)); // Show Numbers


                    if (hour < 13) // If before 1:00pm show left side of graph
                    {
                        Response.Write((chartarray[i]).ToString().Substring(22, 42));
                    }
                    else if (hour < 14) // If after 1:00 pm and before 2:00pm show left side of graph
                    {
                        Response.Write((chartarray[i]).ToString().Substring(32, 42));
                    }
                    else if (hour < 15) // If after 2:00 pm and before 3:00pm show left side of graph
                    {
                        Response.Write((chartarray[i]).ToString().Substring(42, 42));
                    }
                    else // after 3:00pm show right side of graph
                    {
                        Response.Write((chartarray[i]).ToString().Substring(46, 42));
                    }

                    Response.Write((chartarray[i]).ToString().Substring(90, 4));
                }
                Response.Write("</Data>\r\n<Prompt>CSCO Intra-day Chart</Prompt></CiscoIPPhoneImage>\r\n");

                Response.Flush(); // Flush by bufferd response 
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.StackTrace); // Yeah right, we won't have any errors....
            }
            Response.End();
        }

        public byte[] getImageFromUrl(string url)
        {
            System.Net.HttpWebRequest request = null;
            System.Net.HttpWebResponse response = null;
            byte[] b = null;

            request = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(url);
            response = (System.Net.HttpWebResponse)request.GetResponse();

            if (request.HaveResponse)
            {
                if (response.StatusCode == System.Net.HttpStatusCode.OK)
                {
                    Stream receiveStream = response.GetResponseStream();
                    using (BinaryReader br = new BinaryReader(receiveStream))
                    {
                        b = br.ReadBytes(500000);
                        br.Close();
                    }
                }
            }

            return b;
        }
    }
}