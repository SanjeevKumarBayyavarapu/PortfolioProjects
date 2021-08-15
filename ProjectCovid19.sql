/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


/*
Select * 
From ProjectCovid19..CovidDeaths
Where continent is not null
order by 3,4
*/


--Selected location, date, total_cases, new_cases, total_deaths, population Data
Select location, date, total_cases, new_cases, total_deaths, population
From ProjectCovid19..CovidDeaths
Where continent is not null
order by 1,2


--Total Cases vs. Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From ProjectCovid19..CovidDeaths
Where continent is not null
order by 5 desc


--Total Cases vs. Population
Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From ProjectCovid19..CovidDeaths
Where continent is not null
Order by 5 desc


--Highest Infected Rate vs. Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopulationInfectedPercentage
From ProjectCovid19..CovidDeaths
Where continent is not null
Group by location, population
Order by 4 desc


--Highest Death Rate vs. Population
Select location, MAX(convert(int,total_deaths)) as TotalDeathCount
From ProjectCovid19..CovidDeaths
Where continent is not null
Group by location
Order by 2 desc


--Highest Death count by Continent
Select continent, MAX(convert(int,total_deaths)) as TotalDeathCount
From ProjectCovid19..CovidDeaths
Where continent is not null
Group by continent


-- Total Global Cases, Deaths & DeathPercentage
Select SUM(new_cases) as total_cases, SUM(convert(int,new_deaths)) as total_deaths, SUM(convert(int,new_deaths))/SUM(new_cases)*100 as DeathPercentage
From ProjectCovid19..CovidDeaths
Where continent is not null


--*****Total Population vs. Total Vaccinations*****

--*****USING CTE*****--
/*
With POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated )
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
From ProjectCovid19..CovidDeaths CD
Join ProjectCovid19..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date    = CV.date
where CD.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
*/


--*****Using Temp Table for Total Population vs. Total Vaccinations*****--

/*
DROP Table #POPvsVAC
Create Table #POPvsVAC
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #POPvsVAC
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
From ProjectCovid19..CovidDeaths CD
Join ProjectCovid19..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date    = CV.date
Where CD.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #POPvsVAC
*/


--*****Using Temp Table for Total Population vs. Total Vaccinations*****--

DROP Table #POPvsVAC
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
INTO #POPvsVAC  
From ProjectCovid19..CovidDeaths CD
Join ProjectCovid19..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date    = CV.date
Where CD.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #POPvsVAC


--Creating View Tables for visualizations

Create View PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
From ProjectCovid19..CovidDeaths CD
Join ProjectCovid19..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date    = CV.date
Where CD.continent is not null


Select * from PercentPopulationVaccinated 
