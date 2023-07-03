const { makeAugmentedSchema } = require('neo4j-graphql-js');
const { ApolloServer } = require('apollo-server');
const neo4j = require('neo4j-driver');

const typeDefs = `
type Query
{
	faculty(uri: ID!): Faculty
	university(uri: ID!): University
	researchGroup(uri: ID!): ResearchGroup
	lecturer(uri: ID!): Lecturer
	department(uri:ID!): Department
	graduateStudents: [GraduateStudent]
	publications(name: String!): [Publication]
}

type University
{
	uri: ID!
	undergraduateDegreeObtainedByFaculty: [Faculty] @relation(name: "undergraduateDegreeFrom", direction: IN)
	mastergraduateDegreeObtainers: [Faculty] @relation(name: "masterDegreeFrom", direction: IN)
	doctoralDegreeObtainers: [Faculty] @relation(name: "doctoralDegreeFrom", direction: IN)
	undergraduateDegreeObtainedBystudent: [GraduateStudent] @relation(name: "undergraduateDegreeFrom", direction: IN)
	departments: [Department] @relation(name: "subOrganizationOf", direction: IN)
}

interface Faculty
{
	uri: ID!
	telephone: String
	emailAddress: String
	undergraduateDegreeFrom: University @relation(name:"undergraduateDegreeFrom", direction: OUT)
	masterDegreeFrom: University @relation(name:"masterDegreeFrom", direction: OUT)
	doctoralDegreeFrom: University @relation(name:"doctoralDegreeFrom", direction: OUT)
	worksFor: Department @relation(name: "worksFor", direction: OUT)
	teacherOfGraduateCourses: [GraduateCourse] @relation(name:"teacherOf", direction: OUT)
	teacherOfUndergraduateCourses: [UndergraduateCourse] @relation(name:"teacherOf", direction: OUT)
	publications: [Publication] @relation(name: "publicationAuthor", direction: IN)
}

type Department
{
	uri: ID!
	subOrganizationOf: University @relation(name: "subOrganizationOf", direction: OUT)
	head: Professor @relation(name: "headOf", direction: IN)
	researchGroups: [ResearchGroup] @relation(name:"subOrganizationOf", direction: IN)
	faculties: [Faculty] @relation(name:"worksFor", direction: IN)
	professors: [Professor] @relation(name:"worksFor", direction: IN)
	lecturers: [Lecturer] @relation(name:"worksFor", direction: IN)
	graduateStudents: [GraduateStudent] @relation(name:"memberOf", direction: IN)
	undergraduateStudents: [UndergraduateStudent] @relation(name:"memberOf", direction: IN)
}

type ResearchGroup
{
	uri: ID!
	subOrganizationOf: Department @relation(name: "subOrganizationOf", direction: OUT)
}

interface Author
{
	uri: ID!
	telephone: String
	emailAddress: String
}

type Professor implements Faculty & Author
{
	uri: ID!
	telephone: String
	emailAddress: String
	researchInterest: String
	profType: String
	undergraduateDegreeFrom: University @relation(name:"undergraduateDegreeFrom", direction: OUT)
	masterDegreeFrom: University @relation(name:"masterDegreeFrom", direction: OUT)
	doctoralDegreeFrom: University @relation(name: "doctoralDegreeFrom", direction: OUT)
	worksFor: Department @relation(name: "worksFor", direction: OUT)
	teacherOfGraduateCourses: [GraduateCourse] @relation(name:"teacherOf", direction: OUT)
	teacherOfUndergraduateCourses: [UndergraduateCourse] @relation(name:"teacherOf", direction: OUT)
	publications: [Publication] @relation(name: "publicationAuthor", direction: IN)
	supervisedUndergraduateStudents: [UndergraduateStudent] @relation(name:"advisor", direction: IN)
	supervisedGraduateStudents: [GraduateStudent] @relation(name:"advisor", direction: IN)
}


type Lecturer implements Faculty & Author
{
	uri: ID!
	telephone: String
	emailAddress: String
	position: String
	undergraduateDegreeFrom: University @relation(name:"undergraduateDegreeFrom", direction: OUT)
	masterDegreeFrom: University @relation(name:"masterDegreeFrom", direction: OUT)
	doctoralDegreeFrom: University @relation(name: "doctoralDegreeFrom", direction: OUT)
	worksFor: Department @relation(name: "worksFor", direction: OUT)
	teacherOfGraduateCourses: [GraduateCourse] @relation(name:"teacherOf", direction: OUT)
	teacherOfUndergraduateCourses: [UndergraduateCourse] @relation(name:"teacherOf", direction: OUT)
	publications: [Publication] @relation(name: "publicationAuthor", direction: IN)
}

type Publication
{
	uri: ID!
	name: String
	abstract: String
	authors: [Author] @relation(name:"publicationAuthor", direction: OUT)
}

type GraduateStudent implements Author
{
	uri: ID!
	telephone: String
	emailAddress: String
	age: Int
	memberOf: Department @relation(name: "memberOf", direction: OUT)
	undergraduateDegreeFrom: University @relation(name: "undergraduateDegreeFrom", direction: OUT)
	advisor: Professor @relation(name: "advisor", direction: OUT)
	takeGraduateCourses: [GraduateCourse] @relation(name: "takesCourse", direction: OUT)
	assistCourses: [UndergraduateCourse] @relation(name: "teachingAssistantOf", direction: OUT)
}

type UndergraduateStudent
{
	uri: ID!
	telephone: String
	emailAddress: String
	age: Int
	memberOf: Department @relation(name: "memberOf", direction: OUT)
	advisor: Professor @relation(name: "advisor", direction: OUT)
	takeCourses: [UndergraduateCourse] @relation(name: "takesCourse", direction: OUT)
}

type GraduateCourse
{
	uri: ID!
	teachedby: Faculty @relation(name: "teacherOf", direction: IN)
	graduateStudents: [GraduateStudent] @relation(name: "takesCourse", direction: IN)
}

type UndergraduateCourse
{
	uri: ID!
	teachedby: Faculty
	undergraduateStudents: [UndergraduateStudent] @relation(name: "takesCourse", direction: IN)
	teachingAssistants: GraduateStudent @relation(name: "teachingAssistantOf", direction: IN)
}
`;

const schema = makeAugmentedSchema({ typeDefs });

const driver = neo4j.driver(
  'bolt://localhost:7687',
  neo4j.auth.basic('neo4j', 'neo4j')
);

const server = new ApolloServer({ schema, context: { driver } });

server.listen(3003, '0.0.0.0').then(({ url }) => {
  console.log(`GraphQL API ready at ${url}`);
});
