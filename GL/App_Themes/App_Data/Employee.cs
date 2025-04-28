using System.Collections.Generic;

/// <summary>
/// Summary description for Employee
/// </summary>
public class Employee
{
    public int ID { get; set; }
    public string Email { get; set; }

	public Employee()
	{
		//
		// TODO: Add constructor logic here
		//
	}

    public List<Employee> GetEmployeeList()
    {
        List<Employee> empList = new List<Employee>();
        empList.Add(new Employee() { ID = 1, Email = "Mary@somemail.com" });
        empList.Add(new Employee() { ID = 2, Email = "John@somemail.com" });
        empList.Add(new Employee() { ID = 3, Email = "Amber@somemail.com" });
        empList.Add(new Employee() { ID = 4, Email = "Kathy@somemail.com" });
        empList.Add(new Employee() { ID = 5, Email = "Lena@somemail.com" });
        empList.Add(new Employee() { ID = 6, Email = "Susanne@somemail.com" });
        empList.Add(new Employee() { ID = 7, Email = "Johnjim@somemail.com" });
        empList.Add(new Employee() { ID = 8, Email = "Jonay@somemail.com" });
        empList.Add(new Employee() { ID = 9, Email = "Robert@somemail.com" });
        empList.Add(new Employee() { ID = 10, Email = "Krishna@somemail.com" });

        return empList;
    }

}
