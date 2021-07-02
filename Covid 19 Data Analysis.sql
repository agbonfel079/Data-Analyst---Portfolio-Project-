Select * From [dbo].[dbo.CovidDeaths ]
Order by 3,4

Select * From [dbo].[dbo.CovidVacccinations]
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, Population
 From [dbo].[dbo.CovidDeaths ]
 Order by 1,2 

--Total cases vs Total Deaths

 Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
 From [dbo].[dbo.CovidDeaths ]
 Where location like '%states%'
 Order by 1,2 

--Total Cases vs Population 

Select Location, date, total_cases, population, (total_cases/population) *100 AS TotalCasesPercentage
 From [dbo].[dbo.CovidDeaths ]
 Where location like '%states%'
 Order by 1,2 

 --Countries with Highest infection rate

 Select Location, population, MAX(total_cases) AS HighestInfectioncount, 
 MAX(total_cases/population) *100 AS PercentPopulationInfected 
 From [CovidDeaths ]
 --Where location like '%states%'
 Group by location, population 
 Order by PercentPopulationInfected DESC

  Select Location, population,date, MAX(total_cases) AS HighestInfectioncount, 
 MAX(total_cases/population) *100 AS PercentPopulationInfected 
 From [CovidDeaths ]
 --Where location like '%states%'
 Group by location, population, date
 Order by PercentPopulationInfected DESC

 --Countries with the highest Death count per population

 Select Location, MAX(cast(Total_deaths as int )) As TotalDeathCount
  From [dbo].[dbo.CovidDeaths ]
  --Where location like '%states%'
   Where continent is  null
  Group by Location
  Order by  TotalDeathCount DESC
 
  Select * From [dbo].[dbo.CovidDeaths ]
  Where continent is not null
Order by 3,4

--Deaths count by continent 
 Select continent, MAX(cast(Total_deaths as int )) As TotalDeathCount
  From [dbo].[dbo.CovidDeaths ]
  --Where location like '%states%'
   Where continent is not null
  Group by continent 
  Order by  TotalDeathCount DESC

   Select location, SUM(cast(new_deaths as int )) As TotalDeathCount
  From CovidDeaths
  --Where location like '%states%'
   Where continent is  null
   and location not in ('World', 'European Union', 'International')
  Group by location
  Order by  TotalDeathCount desc
  

  --Death count by highest continents

   Select  SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Death,SUM(cast(new_deaths as int))/
   SUM(new_cases) *100 AS DeathPercentage
 From [dbo].[CovidDeaths ]
 --Where location like '%states%'
  Where continent is not null
  --Group By date 
 Order by 1,2 

 --Looking at Total Population and Vaccinations 

 --Using CTE 
 With PopVSVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVacinated)
 as
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVacinated
FROM [dbo].[CovidDeaths ] dea
Join [dbo].[CovidVacccinations] vac 
on dea.location = vac.location
and dea.date = vac.date
 Where dea.continent is not null
 --and dea.location = 'Canada'
 and dea.location = 'Albania'
 --Order by 2,3 
 )
 Select *, (RollingPeopleVacinated/Population) * 100
 From PopVSVac

 --Temp Table 
 DROP Table  #PercentPopulationVaccinated3
 Create Table #PercentPopulationVaccinated3
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
	Insert into  #PercentPopulationVaccinated3
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVacinated
FROM [dbo].[CovidDeaths ] dea
Join [dbo].[CovidVacccinations] vac 
on dea.location = vac.location
and dea.date = vac.date
  --Where dea.continent is not null
 --and dea.location = 'Canada'
 --and dea.location = 'Albania'
 --Order by 2,3 

  Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated3

 --Create View

 Create View PercentPopulationVaccinated4 as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVacinated
FROM [dbo].[CovidDeaths ] dea
Join [dbo].[CovidVacccinations] vac 
on dea.location = vac.location
and dea.date = vac.date
  Where dea.continent is not null

  Select * From [dbo].[PercentPopulationVaccinated4]
