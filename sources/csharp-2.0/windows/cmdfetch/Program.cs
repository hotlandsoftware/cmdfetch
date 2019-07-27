using System;
using System.Collections.Generic;
using System.Drawing;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management;
using System.Text;
using System.Windows.Forms;
using Microsoft.VisualBasic.Devices;
using Microsoft.Win32;

namespace cmdfetch
{
    class Program
    {
        //Booleans
        public static bool nocolor = false;
        public static bool nologo = false;
        public static bool screenshot = false;

        //Strings
        public static string shell = "";

        static void Main(string[] args)
        {
            if (args.Contains("--h"))
            {
                Console.WriteLine(String.Empty);
                Console.WriteLine("--0, --nocolor  Use \"monochrome\" coloring.");
                Console.WriteLine("--n, --nologo   Do not display OS logo.");
                System.Environment.Exit(1);
            }

            if (args.Contains("--nocolor") || args.Contains("--0"))
            {
                nocolor = true;
            }

            if (args.Contains("--nologo") || args.Contains("--n"))
            {
                nologo = true;
            }

            if (args.Contains("--screenshot") || args.Contains("--s"))
            {
                screenshot = true;
            }
            Console.Clear();
            PrintWindowsLogo();
            PrintSpecs();
        }

        public static void PrintSpecs()
        {
            Console.SetCursorPosition(41, 3);
            GetComputerName();
            Console.SetCursorPosition(41, 4);
            GetOS();
            Console.SetCursorPosition(41, 5);
            GetKernel();
            Console.SetCursorPosition(41, 6);
            GetUptime();
            Console.SetCursorPosition(41, 7);
            GetMotherboard();
            Console.SetCursorPosition(41, 8);
            GetShell();
            Console.SetCursorPosition(41, 9);
            GetResolution();
            Console.SetCursorPosition(41, 10);
            GetCPU();
            Console.SetCursorPosition(41, 11);
            GetGPU();
            Console.SetCursorPosition(41, 12);
            GetRAM();
            Console.SetCursorPosition(41, 17);
            /*
            Console.SetCursorPosition(41, 13);
            GetDisks();
            */
        }

        public static void GetComputerName()
        {
            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write(System.Environment.UserName);
                Console.Write("@");
                Console.Write(System.Environment.MachineName);
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.WriteLine(System.Environment.UserName + "@" + System.Environment.MachineName);
            }
        }

        public static void GetOSName()
        {
            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write(System.Environment.UserName);
                Console.Write("@");
                Console.Write(System.Environment.MachineName);
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.WriteLine(System.Environment.UserName + "@" + System.Environment.MachineName);
            }
        }

        public static void GetOS()
        {
            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("OS: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(new ComputerInfo().OSFullName);
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("OS: ");
                Console.Write(new ComputerInfo().OSFullName);
            }
        }

        public static void GetKernel()
        {
            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("Kernel: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(new ComputerInfo().OSVersion);
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("Kernel: ");
                Console.Write(new ComputerInfo().OSVersion);
            }
        }

        public static void GetUptime()
        {
            var ut = new GetSystemUptime();
            var uptimeOutput = new StringBuilder();
            string uptimeDays = ut.UpTime.Days.ToString();
            string uptimeHours = ut.UpTime.Hours.ToString();
            string uptimeMinutes = (ut.UpTime.Minutes < 10
                                        ? "0" + ut.UpTime.Minutes.ToString()
                                        : ut.UpTime.Minutes.ToString());
            string uptimeSeconds = ut.UpTime.Seconds.ToString();
            uptimeOutput.Append(uptimeDays + "d ");
            uptimeOutput.Append(uptimeHours + "h ");
            uptimeOutput.Append(uptimeMinutes + "m ");
            uptimeOutput.Append(uptimeSeconds + "s");

            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("Uptime: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(uptimeOutput.ToString());
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("Uptime: ");
                Console.Write(uptimeOutput.ToString());
            }
        }

        public static void GetMotherboard()
        {
            //Strings
            string ProductPath = "";
            string ProductVer = "";
            //Get value from the Registry
            ProductPath = @"HARDWARE\DESCRIPTION\System\BIOS";
            ProductVer = GetRegKey(ProductPath, "BaseBoardProduct");
            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("Motherboard: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(ProductVer);
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("Motherboard: ");
                Console.Write(ProductVer);
            }
        }

        public static void GetShell()
        {
            Process p = Process.GetCurrentProcess();
            PerformanceCounter parent = new PerformanceCounter("Process", "Creating Process ID", p.ProcessName);
            int ppid = (int)parent.NextValue();

            if (Process.GetProcessById(ppid).ProcessName == "powershell")
            {
                shell = "PowerShell";
            }
            else
            {
                shell = "Command Prompt";
            }

            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("Shell: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(shell);
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("Shell: ");
                Console.Write(shell);
            }
        }

        public static void GetResolution()
        {
            Rectangle resolution = Screen.PrimaryScreen.Bounds;

            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("Resolution: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(resolution.Width + "x" + resolution.Height);
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("Resolution: ");
                Console.Write(resolution.Width + "x" + resolution.Height);
            }
        }

        public static void GetCPU()
        {
            //Strings
            string CPUPath = "";
            string CPUVer = "";
            //Get value from the Registry
            CPUPath = @"HARDWARE\DESCRIPTION\System\CentralProcessor\0";
            CPUVer = GetRegKey(CPUPath, "ProcessorNameString");
            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("CPU: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(CPUVer + " (" + GetCPUCoreCount() + " cores)");
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("CPU: ");
                Console.Write(CPUVer + " (" + GetCPUCoreCount() + " cores)");
            }
        }

        public static string GetCPUCoreCount()
        {
            int CoreCount = 0;
            ManagementScope oMs = new ManagementScope();
            ObjectQuery oQuery2 = new ObjectQuery("Select * from Win32_Processor");
            ManagementObjectSearcher oSearcher2 = new ManagementObjectSearcher(oMs, oQuery2);
            ManagementObjectCollection oCollection2 = oSearcher2.Get();
            foreach (ManagementObject obj in oCollection2)
            {
                CoreCount += int.Parse(obj["NumberOfCores"].ToString());

            }
            return CoreCount.ToString();
        }

        public static void GetGPU()
        {
            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("GPU: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(GetGPUName());
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("GPU: ");
                Console.Write(GetGPUName());
            }
        }

        public static void GetRAM()
        {
            var PCInfo = new ComputerInfo();
            string MaxRamSize = "";
            string UsedRamSize = "";
            MaxRamSize = (PCInfo.TotalPhysicalMemory / (1024 * 1024)).ToString();
            UsedRamSize = ((PCInfo.TotalPhysicalMemory - PCInfo.AvailablePhysicalMemory) / (1024 * 1024)).ToString();

            if (!nocolor)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write("RAM: ");
                Console.ForegroundColor = ConsoleColor.White;
                Console.Write(UsedRamSize + "MB / " + MaxRamSize + "MB");
                Console.ForegroundColor = ConsoleColor.Gray;
            }
            else
            {
                Console.Write("RAM: ");
                Console.Write(UsedRamSize + "MB / " + MaxRamSize + "MB");
            }
        }

        public static void PrintWindowsLogo()
        {
            if (!nologo)
            {
                if (!nocolor)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write("        ,.=:!!t3Z3z.,\n");
                    Console.Write("       :tt:::tt333EE3\n");
                    Console.Write("       Et:::ztt33EEEL");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(" @Ee.,      ..,\n");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write("      ;tt:::tt333EE7");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(" ;EEEEEEttttt33#\n");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write("     :Et:::zt333EEQ.");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(" $EEEEEttttt33QL\n");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write("     :Et:::zt333EEQ.");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(" $EEEEEttttt33QL\n");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write("     it::::tt333EEF");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(" @EEEEEEttttt33F\n");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write("    ;3=*^```\"*4EEV");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(" :EEEEEEttttt33@.\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write("    ,.=::::!t=., ");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write("`");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write(" @EEEEEEtttz33QF\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write("   ;::::::::zt33)");
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.Write("   \"4EEEtttji3P*\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write("  :t::::::::tt33.");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write(":Z3z..  `` ,..g.\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write("  i::::::::zt33F");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write(" AEEEtttt::::ztF\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write(" ;:::::::::t33V");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write(" ;EEEttttt::::t3\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write(" E::::::::zt33L");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write(" @EEEtttt::::z3F\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write("{3=*^```\"*4E3)");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write(" ;EEEtttt:::::tZ`\n");
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write("             ` ");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write(":EEEEtttt::::z7\n");
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write("                 \"VEzjt:;;z>*`\n");
                }

                else
                {
                    Console.Write("        ,.=:!!t3Z3z.,\n");
                    Console.Write("       :tt:::tt333EE3\n");
                    Console.Write("       Et:::ztt33EEEL");
                    Console.Write(" @Ee.,      ..,\n");
                    Console.Write("      ;tt:::tt333EE7");
                    Console.Write(" ;EEEEEEttttt33#\n");
                    Console.Write("     :Et:::zt333EEQ.");
                    Console.Write(" $EEEEEttttt33QL\n");
                    Console.Write("     :Et:::zt333EEQ.");
                    Console.Write(" $EEEEEttttt33QL\n");
                    Console.Write("     it::::tt333EEF");
                    Console.Write(" @EEEEEEttttt33F\n");
                    Console.Write("    ;3=*^```\"*4EEV");
                    Console.Write(" :EEEEEEttttt33@.\n");
                    Console.Write("    ,.=::::!t=., ");
                    Console.Write("`");
                    Console.Write(" @EEEEEEtttz33QF\n");
                    Console.Write("   ;::::::::zt33)");
                    Console.Write("   \"4EEEtttji3P*\n");
                    Console.Write("  :t::::::::tt33.");
                    Console.Write(":Z3z..  `` ,..g.\n");
                    Console.Write("  i::::::::zt33F");
                    Console.Write(" AEEEtttt::::ztF\n");
                    Console.Write(" ;:::::::::t33V");
                    Console.Write(" ;EEEttttt::::t3\n");
                    Console.Write(" E::::::::zt33L");
                    Console.Write(" @EEEtttt::::z3F\n");
                    Console.Write("{3=*^```\"*4E3)");
                    Console.Write(" ;EEEtttt:::::tZ`\n");
                    Console.Write("             ` ");
                    Console.Write(":EEEEtttt::::z7\n");
                    Console.Write("                 \"VEzjt:;;z>*`\n");
                }
            }
            else
            {
                //Do nothing at all
            }
        }

        public static string GetRegKey(string sRegKeyPath, string sRegKeyName)
        {
            RegistryKey regKey = Registry.LocalMachine.OpenSubKey(sRegKeyPath, false);
            string sRegValue = regKey.GetValue(sRegKeyName).ToString();
            regKey.Close();

            return sRegValue;
        }

        public static string GetGPUName()
        {

            ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_VideoController");

            foreach (ManagementObject wmi in searcher.Get())
            {
                try
                {

                    return wmi.GetPropertyValue("Name").ToString();
                }
                catch { }
            }
            return "Unknown";
        }
    }
}
