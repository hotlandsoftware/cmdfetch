using System;
using System.Management;

namespace cmdfetch
{
    class GetSystemUptime
    {
        /// <summary>
        /// Date the system was last booted.
        /// </summary>
        public DateTime BootDate { get; set; }

        /// <summary>
        /// Amount of time the system has been up for.
        /// </summary>
        public TimeSpan UpTime { get; set; }

        public GetSystemUptime()
        {
            BootDate = GetBootTime();
            UpTime = GetUpTime(BootDate);
        }

        /// <summary>
        /// Get the system uptime.
        /// </summary>
        /// <param name="bootDate">Date the system was booted.</param>
        /// <returns>Uptime as <c>TimeSpan</c>.</returns>
        private TimeSpan GetUpTime(DateTime bootDate)
        {
            return DateTime.Now - bootDate;
        }

        /// <summary>
        /// Get the date and time that Windows last booted.
        /// </summary>
        /// <returns>Boot time as <c>DateTime</c>.</returns>
        private DateTime GetBootTime()
        {
            var query = new SelectQuery("SELECT LastBootUpTime FROM Win32_OperatingSystem WHERE Primary = true");
            var mos = new ManagementObjectSearcher(query);

            foreach (ManagementObject mo in mos.Get())
            {
                return ManagementDateTimeConverter.ToDateTime(mo.Properties["LastBootUpTime"].Value.ToString());
            }

            throw new Exception("System LastBootUpTime could not be found.");
        }
    }
}
