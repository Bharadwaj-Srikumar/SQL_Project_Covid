----Covid data analysis

--1) total cases vs total deaths per day, grouped by countries 
 select iso_code,location, date, (total_deaths/total_cases)*100 as Deathsper100Cases
 from PortfolioProject.dbo.covid_deaths
 where location is not null
 order by iso_code,date

 --2) (2.1)total deaths vs total cases ; (2.2)total cases vs population 
 Select  iso_code, location, date,population, total_cases, total_deaths,
 (total_deaths/total_cases)*100 as deathPercentage, (total_cases/population)*100 as TransmissionPercentage
 from PortfolioProject.dbo.covid_deaths
 where continent is not null
 order by iso_code, date

 --3) Infection_rates of countries
 Select location, population, max(total_cases) as highest_cases, max((total_cases)/population)*100 as PercentPopulationInfected
 from PortfolioProject.dbo.covid_deaths
 where continent is not null
 group by location, population
 order by PercentPopulationInfected desc

 --4) Death_rates of countries
 Select location, population, max(convert(int,total_deaths)) as highest_deaths, 
 max((convert(int,total_deaths))/population)*100 as PercentPopulationdead
 from PortfolioProject.dbo.covid_deaths
 where continent is not null
 group by location, population
 order by PercentPopulationdead desc

 --5) Total deaths : Total cases as per continents
 Select location, max(convert(int,total_deaths)) as totalDeaths, max(total_cases) as totalCases, 
 max(convert(int,total_deaths))/max(total_cases)*100 as Death_to_Cases_Percentage
 from PortfolioProject.dbo.covid_deaths
 where continent is null
 group by location
 order by totalDeaths desc

  --6) Total deaths : Population as per continents
 Select location, max(convert(int,total_deaths)) as totalDeaths, 
 max(convert(int,total_deaths))/Population*100 as Death_Percentage
 from PortfolioProject.dbo.covid_deaths
 where continent is null
 group by location, population
 order by Death_Percentage desc


 --7) total new cases and total deaths per day
 Select date, sum(new_cases) as global_new_cases, sum(cast(new_deaths as int)) as global_new_deaths,
 sum(cast(new_deaths as int))/sum(new_cases)*100 as global_death_to_Cases_Ratio
 from PortfolioProject.dbo.covid_deaths
 where continent is not null
 group by date
 order by date, global_new_cases

 --Join tabes to analyse vaccination records  
 --8) vaccination : population analysis
 Select de.continent, de.location, de.date, de.population, vac.new_vaccinations, vac.total_vaccinations,
 (vac.total_vaccinations/population)*100 as vaccinationPercent
 from PortfolioProject.dbo.covid_deaths as de
 join PortfolioProject.dbo.covid_vaccinations as vac
 on de.location = vac.location and de.date=vac.date
 where de.continent is not null
 order by de.continent,de.location, de.date

 --9) Vaccinated Population as time progressed 
 -- use of CTEs to use computed column for further computation
 
 with PeopleVaccinated(Continent, Location, Date, Population, New_Vaccinations, Population_Vaccinated)
 as
 (
 Select de.continent, de.location, de.date, de.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by de.location order by de.location, de.date) as population_vaccinated
 from PortfolioProject.dbo.covid_deaths as de
 join PortfolioProject.dbo.covid_vaccinations as vac
 on de.location = vac.location and de.date=vac.date
 where de.continent is not null
 )
 Select *, Population_Vaccinated/Population
 from PeopleVaccinated
 


 