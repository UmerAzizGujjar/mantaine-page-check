using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;

namespace PMS
{
    /// <summary>
    /// Provider-agnostic data access for external (client) databases.
    /// No compile-time dependency on any Oracle driver: the provider is resolved
    /// at runtime from the connection string's providerName.
    ///   - Oracle.ManagedDataAccess.Client  (no Oracle client install required)
    ///   - System.Data.OracleClient         (legacy, requires Oracle client)
    ///   - System.Data.SqlClient            (SQL Server)
    /// </summary>
    public static class EMRDb
    {
        public sealed class DbParam
        {
            public string Name { get; set; }
            public object Value { get; set; }

            public DbParam(string name, object value)
            {
                Name = name;
                Value = value;
            }
        }

        public static DataTable GetDataTable(string connectionName, string sql, params DbParam[] parameters)
        {
            ConnectionStringSettings cs = ConfigurationManager.ConnectionStrings[connectionName];

            if (cs == null)
            {
                throw new Exception("Connection string not found in Web.config: " + connectionName);
            }

            DbProviderFactory factory;
            try
            {
                factory = DbProviderFactories.GetFactory(cs.ProviderName);
            }
            catch (Exception ex)
            {
                throw new Exception(
                    "Cannot load the ADO.NET data provider '" + cs.ProviderName + "' for connection '" + connectionName + "'. " +
                    "If this is Oracle.ManagedDataAccess.Client, deploy Oracle.ManagedDataAccess.dll to the application bin folder " +
                    "and make sure it is registered under <system.data><DbProviderFactories> in Web.config. " +
                    "Details: " + ex.Message, ex);
            }

            DataTable dt = new DataTable();

            using (DbConnection con = factory.CreateConnection())
            {
                con.ConnectionString = cs.ConnectionString;

                using (DbCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = sql;
                    cmd.CommandTimeout = 300;

                    if (parameters != null)
                    {
                        foreach (DbParam p in parameters)
                        {
                            DbParameter prm = cmd.CreateParameter();
                            prm.ParameterName = p.Name;
                            prm.Value = p.Value ?? DBNull.Value;
                            cmd.Parameters.Add(prm);
                        }
                    }

                    con.Open();

                    using (DbDataAdapter da = factory.CreateDataAdapter())
                    {
                        da.SelectCommand = cmd;
                        da.Fill(dt);
                    }
                }
            }

            return dt;
        }

        /// <summary>
        /// Converts a DataTable to a list of case-insensitive key/value rows so the
        /// UI can render whatever columns the query returns (schema-agnostic).
        /// </summary>
        public static List<Dictionary<string, string>> ToRows(DataTable dt)
        {
            List<Dictionary<string, string>> rows = new List<Dictionary<string, string>>();

            if (dt == null)
            {
                return rows;
            }

            foreach (DataRow r in dt.Rows)
            {
                Dictionary<string, string> row = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

                foreach (DataColumn c in dt.Columns)
                {
                    row[c.ColumnName] = r[c] == DBNull.Value ? "" : r[c].ToString();
                }

                rows.Add(row);
            }

            return rows;
        }

        public static string[] GetColumnNames(DataTable dt)
        {
            List<string> names = new List<string>();

            if (dt != null)
            {
                foreach (DataColumn c in dt.Columns)
                {
                    names.Add(c.ColumnName);
                }
            }

            return names.ToArray();
        }
    }
}
