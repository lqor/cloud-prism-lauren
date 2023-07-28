public with sharing class Person implements Comparable {
  public String Name;
  public Integer Age;
  public Person Mother;
  public Person Father;

  public Person(String name, Integer age, Person mother, Person father) {
    this.Name = name;
    this.Age = age;
    this.Mother = mother;
    this.Father = father;
  }

  public List<Person> traverseFamilyTree(Person person) {
    List<Person> familyMembers = new List<Person>();

    if (person == null) {
      return familyMembers;
    } else {
      familyMembers.add(person);
    }

    familyMembers.addAll(traverseFamilyTree(person.Mother));
    familyMembers.addAll(traverseFamilyTree(person.Father));

    return familyMembers;
  }

  public List<Person> sortAsc(List<Person> familyMembers) {
    List<Person> familyMembersAscending = new List<Person>(familyMembers);

    familyMembersAscending.sort();

    return familyMembersAscending;
  }

  public List<Person> sortDesc(List<Person> familyMembers) {
    List<Person> familyMembersDescending = new List<Person>();
    List<Person> familyMembersAscending = sortAsc(familyMembers);

    for (Integer i = familyMembersAscending.size() - 1; i >= 0; i--) {
      familyMembersDescending.add(familyMembersAscending.get(i));
    }

    return familyMembersDescending;
  }

  public Person findOldestMember(List<Person> familyMembers) {
    return sortDesc(familyMembers).get(0);
  }

  public Person findYoungestMember(List<Person> familyMembers) {
    return sortAsc(familyMembers).get(0);
  }

  public Integer compareTo(Object toCompare) {
    Person personToCompare = (Person) toCompare;

    if (this.Age > personToCompare.Age) {
      return 1;
    } else if (this.Age < personToCompare.Age) {
      return -1;
    }

    return 0;
  }
}
